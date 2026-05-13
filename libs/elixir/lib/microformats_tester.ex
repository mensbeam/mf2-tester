defmodule MicroformatsTester do
  def main(args) do
    if length(args) != 2 do
        IO.puts("Usage: test_one <input_file> <base_url>")
        exit(1)
    end
    file_name = Enum.at(args, 0)
    base_url = Enum.at(args, 1)

    html = File.read!(file_name)
    out = JSON.encode!(Microformats2.parse(html, base_url))

    IO.puts(out)
  end
end
