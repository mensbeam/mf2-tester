defmodule MicroformatsTester do
  def main(args) do
    if length(args) != 1 do
        IO.puts("Usage: test_one <inputfile>")
        exit(1)
    end
    file_name = Enum.at(args, 0)

    base_url = if String.contains?(file_name, "/microformats-v2-unit"), do: "http://example.test/", else: "http://example.com/"

    html = File.read!(file_name)
    out = JSON.encode!(Microformats2.parse(html, base_url))

    IO.puts(out)
  end
end
