return function(getonreceive, getondisconnect)
 
 local holder = function()
  return {
   id = math.random(1000),
   req = nil,
   res = nil
  }
 end
 
 local use = function(self, handler, opts)
  if not(next(self.handlers)) then
   self.handlers.handler = handler
   self.handlers.opts = opts
  else
   local tmp = self.handlers
   while not (tmp == nil) do
    print("In handler " .. tmp.handler)
    local next = tmp.next
    if next == nil then
     print("Next handler " .. handler .. " will be after " .. tmp.handler)
     tmp.next = { handler = handler, opts = opts }
    end
    tmp = next
   end
  end
  collectgarbage("collect")
 end

 local listen = function(self, port)
  -- Last handler returns 404 - NOT FOUND
  self:use("http_default_handler.lc")
  -- Forget about useless methods after listening
  self.use = nil
  self.listen = nil

  local srv = net.createServer(net.TCP, 30)
  -- Listen method
  srv:listen(port, function(conn)
   collectgarbage("collect")
   print("Begin Http request: " .. node.heap())
   local connholder = holder()
   print("Connection initialized with id " .. connholder.id)
   conn:on("receive", getonreceive(connholder))
   conn:on("disconnection", getondisconnect(connholder))
   print("Request callbacks have been set: " .. node.heap())
  end)

  print("Server listening on port " .. tostring(port))
  collectgarbage("collect")
  print("Available memory is " .. node.heap() .. " bytes.")
 end

 return {
  use = use,
  listen = listen,
  handlers = {}
 }
end