defmodule HelloWorld1 do

    import CloudILogger

    def cloudi_service_init(_args, _prefix, _timeout, dispatcher) do
        :cloudi_service.subscribe(dispatcher, 'hello_world1/get')
        {:ok, :undefined}
    end

    def cloudi_service_handle_request(_type, _name, _pattern,
                                      _requestinfo, _request,
                                      _timeout, _priority,
                                      _transid, _pid, state, _dispatcher) do
        {:reply, "Hello World!", state}
    end

    def cloudi_service_handle_info(request, state, _dispatcher) do
        log_warn('Unknown info "~p"', [request])
        {:noreply, state}
    end

    def cloudi_service_terminate(_reason, _timeout, _state) do
        :ok
    end
end
