require "socket"
require "uri"

LOG = "bbs.log"
ss = TCPServer.open(15120)
while true
 Thread.start(ss.accept) do |s|
   begin
     path, params = s.gets.split[1].split("?")


     header = ""
     body = ""
     myname = "名無し"
     value = ""
     if (params != nil)
       params.split("&").each do |param|
          pair = param.split("=")
          pname = pair[0]
          pvalue = URI.decode(pair[1] == nil ? "" : pair[1])
          myname = pvalue if (pname == "myname")
          value = pvalue if (pname == "value")
        end
     end
     if (path == "/")
       status = "200 OK"
       header = "Content-Type: text/html; charset=iso-2022-JP"

       log = []
       message = ""

       if (value != "")
	 value = value.gsub(/(\r\n|\r|\n)/, "<br />") # 改行の置換
         log.unshift("<div style=background:url(http://frame-illust.com/fi/wp-content/uploads/2015/01/da3709be5136c32a273e5cc0b357b82b.png);><b>" + myname + " (" + Time.new.to_s + ")</b> <br> " + value + "</div><br>\n")
         f = open(LOG, "a")
         log.each{|line|
           f.print line
         }
         f.close
       end

       f = open(LOG)
       f.each{|line|
         message += line
       }
       f.close

       body = "<html><body>"
       body += "<div style=background:url(http://frame-illust.com/fi/wp-content/uploads/2015/01/5e46053a1e8fb255da7f860e6b3981e1.png);background-size:cover;>"
       body += "<a href=\"http://localhost:15120\">HOME</a><br><br>"
       body += "<div>こんにちは</div><br>"
       body += "<form method=get>"
       body += "name：<input type=text name=myname value=とくめい><br>"
       body += "<textarea name=value rows=2 cols=25 placeholder=comment></textarea><br>" # <input type=text name=value>
       body += "<input type=submit value=送信！>"
       body += "</form><hr></div>"
       body = body+message
       body = body + "</body></html>"

     else
       status = "302 Moved"
       header = "Location: /"
     end
     s.write("HTTP/1.0 " + status + "\r\n")
     s.write(header + "\r\n") if (header != "")
     s.write("\r\n")
     s.write(body)
     puts Time.new.to_s + " " + status + " " + path
     s.close
   end
 end
end