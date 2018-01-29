require "socket"
require "uri"

LOG = "bbs.log"
ss = TCPServer.open(15120)
id =0
while true
 Thread.start(ss.accept) do |s|
   begin
     path, params = s.gets.split[1].split("?")


     header = ""
     body = ""
     myname = "名無し"
     value = ""
	 emotion = ""
     if (params != nil)
       params.split("&").each do |param|
          pair = param.split("=")
          pname = pair[0]
          pvalue = URI.decode(pair[1] == nil ? "" : pair[1])
          myname = pvalue if (pname == "myname")
          value = pvalue if (pname == "value")
		  emotion = pvalue if (pname == "emotion")
		  id =pvalue if (pname == "id")
        end
     end
     if (path == "/")
       status = "200 OK"
       header = "Content-Type: text/html; charset=iso-2022-JP"

       log = []
       message = ""

       if (value != "")
	   	 id += 1
		 id_str = id.to_s
	 	 value = value.gsub(/(\r\n|\r|\n)/, "<br />") # 改行の置換
         log.unshift("<div style=background:pink;margin:10px;><b>" + id_str + "." + myname + " (" + Time.new.to_s + ")</b> <br> " + value + "<br>" + emotion + "<br></div>\n")
         f = open(LOG, "a")
         log.each{|line|
           f.print line
         }
         f.close
       end

       f = open(LOG)
       f.each{|line|
         message += line #message = line+message
       }
       f.close

       body = "<html><body>HOMEへ戻るようにしよう！<br><br>"
       body += "<form method=get>"
	   body += "<img src=https://pbs.twimg.com/media/C2arRY9VEAAanSu.jpg style=width:400px;height:auto;display:block;>"
	   body += "コメントする<br>"
       body += "name：<input type=text name=myname value=とくめい><br>"
	   body += "<div style=width:400px;>"
       body += "<textarea name=value rows=4 style=width:400px; placeholder=comment></textarea><br>" # <input type=text name=value>
	   body += "<div style=margin:table;><input type=radio name=emotion value=にこにこ checked=checked style=margin:auto;>にこにこ"
	   body += "<input type=radio name=emotion value=ぷんぷん style=margin:auto;>ぷんぷん</div>"
       body += "<input type=submit value=送信！ style=background:yellow;margin:auto;display:block;width:60px;height:30px;border-radius:5px;>"
	   body += "</div></div>"
       body += "</form><hr>"
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