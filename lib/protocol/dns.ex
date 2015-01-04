defimpl String.Chars, for: Protocol.Dns do
  def to_string(dns) do
    String.strip("""
    DNS:
        #{dns.header}
        Length:           #{byte_size(dns.data)}
        Parsed:
          Questions:      #{Enum.map(elem(dns.parsed, 0), &String.Chars.to_string/1)}
          Answers:        #{Enum.map(elem(dns.parsed, 1), &String.Chars.to_string/1)}
          Authorities:    #{Enum.map(elem(dns.parsed, 2), &String.Chars.to_string/1)}
          Additionals:    #{Enum.map(elem(dns.parsed, 3), &String.Chars.to_string/1)}
        Raw:              #{ExPcap.Binaries.to_raw(dns.data)}
    """)
  end
end

defimpl String.Chars, for: Protocol.Dns.Header do
  def to_string(dns) do
    String.strip("""
        id:               #{ExPcap.Binaries.to_string(dns.id)}
        qr:               #{ExPcap.Binaries.to_string(dns.qr)}
        opcode:           #{ExPcap.Binaries.to_string(dns.opcode)}
        aa:               #{ExPcap.Binaries.to_string(dns.aa)}
        tc:               #{ExPcap.Binaries.to_string(dns.tc)}
        rd:               #{ExPcap.Binaries.to_string(dns.rd)}
        ra:               #{ExPcap.Binaries.to_string(dns.ra)}
        z:                #{ExPcap.Binaries.to_string(dns.z)}
        rcode:            #{ExPcap.Binaries.to_string(dns.rcode)}
        qdcnt:            #{ExPcap.Binaries.to_string(dns.qdcnt)}
        ancnt:            #{ExPcap.Binaries.to_string(dns.ancnt)}
        nscnt:            #{ExPcap.Binaries.to_string(dns.nscnt)}
        arcnt:            #{ExPcap.Binaries.to_string(dns.arcnt)}
    """)
  end
end

defimpl PayloadType, for: Protocol.Dns do
  def payload_parser(dns) do
    nil
    # case dns.header.qr do
    #   <<0 :: size(1)>> -> Protocol.Dns.Question
    #   <<1 :: size(1)>> -> Protocol.Dns.ResourceRecord
    # end
  end
end

defimpl PayloadParser, for: Protocol.Dns do
  def from_data(data) do
    Protocol.Dns.from_data data
  end
end

defmodule Protocol.Dns.Header do
  defstruct id:      <<>>,
            qr:      <<>>,
            opcode:  <<>>,
            aa:      <<>>,
            tc:      <<>>,
            rd:      <<>>,
            ra:      <<>>,
            z:       <<>>,
            rcode:   <<>>,
            qdcnt:   <<>>,
            ancnt:   <<>>,
            nscnt:   <<>>,
            arcnt:   <<>>
end

defmodule Protocol.Dns do

  @bytes_in_header 12

  defstruct header: %Protocol.Dns.Header{},
            parsed: {
                      [%Protocol.Dns.Question{}],         # questions
                      [%Protocol.Dns.ResourceRecord{}],   # answers
                      [%Protocol.Dns.ResourceRecord{}],   # authorities
                      [%Protocol.Dns.ResourceRecord{}],   # additionals
                      <<>>      # leftover bytes
                    },
            data: <<>>

  def header(data) do
    <<
      id        :: bytes-size(2),
      qr        :: bits-size(1),
      opcode    :: bits-size(4),
      aa        :: bits-size(1),
      tc        :: bits-size(1),
      rd        :: bits-size(1),
      ra        :: bits-size(1),
      z         :: bits-size(3),
      rcode     :: bits-size(4),
      qdcnt     :: unsigned-integer-size(16),
      ancnt     :: unsigned-integer-size(16),
      nscnt     :: unsigned-integer-size(16),
      arcnt     :: unsigned-integer-size(16),
      _payload  :: binary
    >> = data
    h = %Protocol.Dns.Header{
      id:     id,
      qr:     qr,
      opcode: opcode,
      aa:     aa,
      tc:     tc,
      rd:     rd,
      ra:     ra,
      z:      z,
      rcode:  rcode,
      qdcnt:  qdcnt,
      ancnt:  ancnt,
      nscnt:  nscnt,
      arcnt:  arcnt
    }
    IO.puts "dns header:"
    IO.inspect h
    h
  end

  def from_data(data) do
    << _header :: bytes-size(@bytes_in_header), payload :: binary >> = data
    header = header(data)
    dns = Protocol.Dns.ResourceRecord.read_dns(header, payload)
    IO.puts "dns dns dns:"
    IO.inspect dns
    %Protocol.Dns{
      header: header,
      parsed: dns,
      data: payload
    }
  end

end
