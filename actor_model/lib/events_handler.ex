defmodule EventsHandler do
  use Task
  @joiner_subscriber_port 2054

  def start_link(arg) do
    Task.start_link(__MODULE__, :run, [arg])
  end

  def handle_event(supervisor_pid, message) do
    # dynamically create tasks
    event_handler =
      Task.Supervisor.async(supervisor_pid, fn ->
        PreBrokerProcessor.start_link(message)
      end)
  end

  def fix_xml(xml) do
    xml = String.replace(xml, "us=", "us='")
    [{index, length}] = Regex.run(~r{[0-9]>}, xml, return: :index)
    {head, tail} = String.split_at(xml, index + length - 1)
    head <> "'" <> tail
  end

  def convert_data(supervisor_pid, new_event) do
    new_event = %{
      new_event
      | :data => String.replace(new_event.data, "<SensorReadings", "\"<SensorReadings")
    }

    new_event = %{
      new_event
      | :data => String.replace(new_event.data, "</SensorReadings>", "</SensorReadings>\"")
    }

    {status, new_data} = JSON.decode(new_event.data)

    if status == :ok do
      message = new_data["message"]

      if is_map(message) do
        handle_event(supervisor_pid, message)
      end

      if is_binary(message) do
        message = fix_xml(message)
        message = XmlToMap.naive_map(message)
        handle_event(supervisor_pid, message)
      end
    end
  end

  def wait_for_event(supervisor_pid) do
    receive do
      %EventsourceEx.Message{id: id, event: event, data: data, dispatch_ts: dispatch_ts} ->
        convert_data(supervisor_pid, %{
          :id => id,
          :event => event,
          :data => data,
          :dispatch_ts => dispatch_ts
        })
    end

    # infinite loop
    wait_for_event(supervisor_pid)
  end

  def run(arg) do

    {:ok, socket} = :gen_udp.open(@joiner_subscriber_port)

    children = [
      {ForecastStation,
       %{
         :atmo_pressure => nil,
         :wind_speed => nil,
         :light => nil,
         :humidity => nil,
         :temperature => nil,
         :timestamp_atmo_wind => nil,
         :timestamp_light => nil,
         :timestamp_hum_temp => nil
       }},
      {PreBrokerProcessor, nil},
      {JoinerSubscriber, []}
    ]

    Supervisor.start_link(children, strategy: :one_for_all)

    Task.async(fn -> JoinerSubscriber.listen_broker end)

    {:ok, pid} = EventsourceEx.new("http://localhost:4000/iot", stream_to: self())
    {:ok, pid} = EventsourceEx.new("http://localhost:4000/sensors", stream_to: self())
    {:ok, pid} = EventsourceEx.new("http://localhost:4000/legacy_sensors", stream_to: self())

    # set event-handlers supervisor
    {:ok, supervisor_pid} = Task.Supervisor.start_link()
    wait_for_event(supervisor_pid)
  end
end
