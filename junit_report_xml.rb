require 'nokogiri'


#->Result should be an hash in following format
result={"SampleTest2_Class"=>{"class"=>"SampleTest2", "testcase"=>"Test1", "status"=>"pass", "reason"=>"NA", "time"=>8.01, "backtrace"=>"NA"}}

#block to generate junit xml report
def generate_junit_xml(result)
  passed,failed,skipped,time=generate_report(result)
  total=passed+skipped+failed
  suite=Nokogiri::XML::Builder.new(:encoding => 'UTF-8') do |xml|
      xml.testsuite(:failures=>failed ,:name=>"Goblin Test results" ,:skipped=>skipped ,:tests=>total,:time=>time){
          for k,v in result
              testcase= result[k]['testcase'].split('::')[-1]
              if result[k]['status']=="pass"
                  xml.testcase(:classname=>result[k]['class'] ,:name=>testcase,:time=>result[k]["time"]){
                      xml.send (:"system-out"){ 
                          xml.cdata "Passed"
                      }
                  }
              elsif result[k]['status']=="fail" or result[k]['status']=='error'
                  xml.testcase(:classname=>result[k]['class'] ,:name=>testcase,:time=>result[k]["time"]){
                      xml.failure(:message=>result[k]['backtrace'][0]){
                          xml.cdata result[k]['backtrace']
                      }
                  }
              elsif result[k]['status']=='skipped'
                  xml.testcase(:classname=>result[k]['class'] ,:name=>testcase,:time=>result[k]["time"]){
                      xml.send(:"skipped")
                  }
              else
                  puts "skipping"
              end   
          end 
      }
  end
  return suite.to_xml
end


#generate and write to "junit xm file"
xml_data=runner.generate_junit_xml(report)
file = File.new("junit-report.xml", "wb")
file.write(xml_data)
file.close
