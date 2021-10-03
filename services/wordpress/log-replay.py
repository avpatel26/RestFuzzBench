import apache_log_parser
import sys
import requests
from os import listdir
from os.path import isfile, join

path="/home/ubuntu/accesslogs/"
username=sys.argv[1]
password=sys.argv[2]
onlyfiles = [f for f in listdir(path) if isfile(join(path, f))]

for file in onlyfiles:
    f=open(path+file)
    for x in f:
        line_parser= apache_log_parser.make_parser("%h %l %u %t \"%r\"")
        json=line_parser(x)
        host=json['remote_host']
        method=json['request_method']
        url=json["request_url"]
        furl="http://"+host+json["request_url"]
        print(furl)
        try:
            if(method=='GET'):
                requests.get(furl,auth=(username,password))
            elif(method=='POST'):
                requests.post(furl,auth=(username,password))
            elif(method=='PUT'):
                requests.put(furl,auth=(username,password))
            elif(method=='DELETE'):
                requests.delete(furl,auth=(username,password))
            elif(method=='PATCH'):
                requests.patch(furl,auth=(username,password))
        except ConnectionError:
            print("Connection is not found")
            break


