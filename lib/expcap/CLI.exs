# GlobalHeader.read_file("/tmp/dns.cap") |> GlobalHeader.read |> IO.inspect

f = File.open!("/tmp/dns.cap")
GlobalHeader.from_file(f) |> IO.inspect
File.close(f)