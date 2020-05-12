defmodule EventListener do
  use Task


  def start_link(arg) do
    Task.start_link(__MODULE__, :run, [arg])
  end


  def handle_event(supervisor_pid, message) do
    # dynamically create tasks, and send the message data to a process-worker - PreBrokerProcessor
    # the PreBrokerProcessor has the role tocalculate the average value of two sensors and
    # then to send it to the broker
    event_handler = Task.Supervisor.async(supervisor_pid, fn -> PreBrokerProcessor.start_link(message) end)
  end

  # this function is used to fix a format issue in the xml data string
  # but already not needed since the docker image was updated
#  def fix_xml(xml) do
#    xml = String.replace(xml, "us=", "us='")
#    [{index, length}] = Regex.run(~r{[0-9]>}, xml, return: :index)
#    {head, tail} = String.split_at(xml, index + length - 1)
#    head <> "'" <> tail
#  end


  def convert_data(supervisor_pid, new_event) do

    # these thow are used to fix a problem from the xaml string
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

      # if map then it has been already converted whit JSON.decode above
      if is_map(message) do
        handle_event(supervisor_pid, message)
      end

      # else, is is a scring, and most probably representing an xml
      if is_binary(message) do
        # converting an xml string into a map, then handle event
        message = fix_xml(message)
        message = XmlToMap.naive_map(message)
        handle_event(supervisor_pid, message)
      end
    end
  end


  def wait_for_event(supervisor_pid) do
    receive do
      # when got an event
      %EventsourceEx.Message{id: id, event: event, data: data, dispatch_ts: dispatch_ts} ->
        # send the event's data-info in the covert data function, necause
        # the sensor data (messge data) may arrive in xml format or json
        # it should be converted in a common for mat for elixir - a map conveniently
        convert_data(supervisor_pid, %{
          :id => id,
          :event => event,
          :data => data,
          :dispatch_ts => dispatch_ts
        })
    end

#    :timer.sleep(1000)

    # infinite loop
    wait_for_event(supervisor_pid)
  end


  def run(arg) do
    # start listeninf for ecents from all three sources
    {:ok, pid} = EventsourceEx.new("http://localhost:4000/iot", stream_to: self())
    {:ok, pid} = EventsourceEx.new("http://localhost:4000/sensors", stream_to: self())
    {:ok, pid} = EventsourceEx.new("http://localhost:4000/legacy_sensors", stream_to: self())

    # set event-handlers supervisor
    # start a supervised task-process
    {:ok, supervisor_pid} = Task.Supervisor.start_link()

    # send the process id so that is can be used further
    wait_for_event(supervisor_pid)
  end

end
