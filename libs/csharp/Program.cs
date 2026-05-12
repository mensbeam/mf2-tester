using System.Text;
using System.Text.Json;
using Microformats.Grammar;

class Program {
    static int Main(string[] args) {
        if (args.Length < 1) {
            Console.WriteLine("Usage: csharp <inputfile>");
            return 1;
        }
        var filename = args[0];
        var baseUrl = "http://example.com/";
        if (filename.Contains("/microformats-v2-unit/")) {
            baseUrl = "http://example.test";
        }

        var d = File.ReadAllText(filename, Encoding.UTF8);
        var p = new Microformats.Mf2().WithOptions(o => {
            o.DiscoverLang = false;
            o.UpgradeClassicMicroformats = true;
            o.BaseUri = new Uri(baseUrl);
            return o;
        });
        var r = p.Parse(d);

        string SerializeMicroformat(MfSpec item) {
            var json = "";
            json += "{\"type\":" + JsonSerializer.Serialize(item.Type);
            if (item.Id != null) {
                json += ",\"id\":\"" + item.Id + "\"";
            }
            if (item.Value != null) {
                json += ",\"value\":" + JsonSerializer.Serialize(item.Value);
            }
            json += ",\"properties\":{";
            var first = true;
            foreach ((string k, MfValue[] v) in item.Properties) {
                if (first) {
                    first = false;
                } else {
                    json += ",";
                }
                json += JsonSerializer.Serialize(k) + ":[";
                for (int b = 0; b < v.Length; b++) {
                    if (b > 0) {
                        json += ",";
                    }
                    var prop = v[b].Get();
                    if (prop is string s) {
                        json += JsonSerializer.Serialize(s);
                    } else if (prop is MfImage i) {
                        json += "{\"alt\":" + JsonSerializer.Serialize(i.Alt) + ",\"value\":" + JsonSerializer.Serialize(i.Value) + "}";
                    } else if (prop is MfEmbedded e) {
                        json += "{\"html\":" + JsonSerializer.Serialize(e.Html) + ",\"value\":" + JsonSerializer.Serialize(e.Value) + "}";
                    } else if (prop is MfSpec m) {
                        json += SerializeMicroformat(m);
                    }
                }
                json += "]";
            }
            json += "}";
            if (item.Children.Count > 0) {
                json += ",\"children\":[";
                for (int b = 0; b < item.Children.Count; b++) {
                    if (b > 0) {
                        json += ",";
                    }
                    json += SerializeMicroformat(item.Children[b]);
                }
                json += "]";
            }
            json += "}";
            return json;
        }

        var json = "";
        json += "{\"items\":[";
        for (int a = 0; a < r.Items.Length; a++) {
            if (a > 0) {
                json += ",";
            }
            json += SerializeMicroformat(r.Items[a]);
        }
        json += "],\"rels\":{";
        var first = true;
        foreach ((string k, string[] v) in r.Rels) {
            if (first) {
                first = false;
            } else {
                json += ",";
            }
            json += JsonSerializer.Serialize(k) + ":" + JsonSerializer.Serialize(v);
        }
        json += "},\"rel-urls\":{";
        first = true;
        foreach ((string k, MfRelUrlResult v) in r.RelUrls) {
            if (first) {
                first = false;
            } else {
                json += ",";
            }
            json += JsonSerializer.Serialize(k) + ":{";
            json += JsonSerializer.Serialize("rels") + ":" + JsonSerializer.Serialize(v.Rels);
            if (v.Text != null) {
                json += "," + JsonSerializer.Serialize("text") + ":" + JsonSerializer.Serialize(v.Text);
            }
            if (v.Title != null) {
                json += "," + JsonSerializer.Serialize("title") + ":" + JsonSerializer.Serialize(v.Title);
            }
            if (v.Type != null) {
                json += "," + JsonSerializer.Serialize("type") + ":" + JsonSerializer.Serialize(v.Type);
            }
            if (v.Media != null) {
                json += "," + JsonSerializer.Serialize("media") + ":" + JsonSerializer.Serialize(v.Media);
            }
            if (v.HrefLang != null) {
                json += "," + JsonSerializer.Serialize("hreflang") + ":" + JsonSerializer.Serialize(v.HrefLang);
            }
            json += "}";
        }
        json += "}";
        json += "}";
        Console.WriteLine(json);
        return 0;
    }
}
