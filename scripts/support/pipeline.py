#!/usr/bin/env python
###******************************************************###
###                                                      ###
###     Author: Jacob Hurst                              ###
###     File: pipeline.py                                ###
###     Date: 19 Dec 2006                                ###
###     Description:                                     ###
###     A generic pipeline module.                       ###
###                                                      ###
###******************************************************###
import xml.sax
import sys,os
import subprocess,getopt
import pprint
###******************************************************###
class PipelineException(Exception):
    value="Pipeline Exception: %s"

###******************************************************###

class PipelineConfig(xml.sax.handler.ContentHandler):
    ###*************************************************
    def __init__(self):
        self.acaca_config = False
        self.buffer=""
        self.currentProgram=""
        self.pipelineName=""
        self.programExecutables={}
        self.programModules={}
        self.programs={}
        self.programArguments={}
        self.programOrder=[]
        self.config_data = {}
    ###*************************************************
    def startElement(self,name,attrs):
        if name=="program":
            # Error check the program entry
            if "description" in attrs:
                self.currentProgram=attrs["description"]
            else:
                # if there is no program description raise an exception
                msg="No description for program entry."
                raise PipelineException,PipelineException.value % msg
            if not "function" in attrs and not "executable" in attrs:
                # if there is neither a function argument and no executable argument
                msg="function or executable arguments not present for: %s"%(attrs["description"])
                raise PipelineException,PipelineException.value % msg
            # Add the program data to the class structures
            self.programOrder.append(self.currentProgram)
            if "function" in attrs:
                # now find the first "." and take everyting up to that dot
                m=attrs["function"]
                pos=m.find(".")
                if pos==-1:
                    # perhaps makes it difficult to run stuff from
                    # the standard library.
                    msg="Need a modulename.function argument"
                    raise PipelineException,PipelineException.value % msg
                else:
                    n=m[:pos]
                self.programModules[self.currentProgram]=n
                o=m[pos+1:]
                o = self.look_and_replace_config_info(o)
                self.programExecutables[self.currentProgram]=o
            elif "executable" in attrs:
                o =attrs["executable"]
                o = self.look_and_replace_config_info(o)
                self.programExecutables[self.currentProgram] = o
        elif name=="pipeline":
            if "name" in attrs:
                self.pipelineName=attrs["name"]
        elif name=="argument":
            self.buffer=""
        elif name=="acaca_config":
            self.acaca_config = True
            self.buffer=""
        self.readChars=True
    ###*************************************************
    def endElement(self,name):
        if len(self.buffer)>0 and self.buffer!="\n":
            if self.buffer.find("\n")==0:
                self.buffer=self.buffer[1:]
            #self.configData[name]=self.buffer
        self.readChars=False
        if name=="argument":
            if self.currentProgram not in self.programArguments:
                self.programArguments[self.currentProgram]=[]
            self.programArguments[self.currentProgram].append(self.look_and_replace_config_info(self.buffer))
        elif name == "acaca_config":
            self.acaca_config = False

        if self.acaca_config == True:
            self.config_data[name] = self.buffer           
         
        self.buffer=""
    ###*************************************************
    def look_and_replace_config_info(self, s_in_q):
        """ checks a string and replaces any config string with the config example. """
        for config_st in self.config_data:
            s_in_q = s_in_q.replace(config_st,self.config_data[config_st])
        return s_in_q
    ###*************************************************
    def get_config_item(self, i_in_q):
        """ returns the abysis_configuration of a given item. """
        if i_in_q in self.config_data:
            return self.config_data[i_in_q]
        else:
            return None
    ###*************************************************
    def characters(self,data):
        if self.readChars==True:
            #self.buffer=self.buffer.strip("\n")
            self.buffer=self.buffer+data

###******************************************************###
class Pipeline:
    ###*************************************************
    def __init__(self,configfile="config.xml",debug="False"):
        """ Parses the xml configuration file. """
        self.debug=debug
        # setup the xml parser
        parser=xml.sax.make_parser()
        self.handler=PipelineConfig()
        parser.setContentHandler(self.handler)
        # now parse the file
        #try:
        parser.parse(configfile)
        #except:
        #    print "Pipeline Error: failed to parse:",configfile
        #    sys.exit(1)
        # now if necessary set python home
        p_home = self.handler.get_config_item("acaca_python_home")
        if p_home != None:
            sys.path.append(p_home)
    ###*************************************************
    def run(self):
        """ runs the pipeline in the set order. if in debug mode user will
        be given the option not to run the program. """
        print "Running Pipeline:",self.handler.pipelineName
        if self.debug==True:
            for progs in self.handler.programOrder:
                fire=self.shouldWeFire(progs)
                if fire==True:
                    self.runSingleProgram(progs)
        else:
            for progs in self.handler.programOrder:
                self.runSingleProgram(progs)
    ###*************************************************
    def runSingleProgram(self,prog):
        """ Runs a specific program. """
        # first check to see if the program is wrapped by a module.
        if prog in self.handler.programModules:
            exec "from %s import *"%(self.handler.programModules[prog])
            args=self.handler.programArguments[prog]
            exe=self.handler.programExecutables[prog]
            # build up the execute string according to the number of
            # arguments.
            estring="%s("%(exe)
            for a in args:
                estring=estring+a+","
            estring=estring[:-1]
            estring=estring+")"
            exec estring
        else:
            # the program is not a python function but a standalone program
            exe=self.handler.programExecutables[prog]
            exe = exe.strip()
            args=[]
            args.append(exe)
            if prog in self.handler.programArguments:
                for a in self.handler.programArguments[prog]:
                    a = a.strip()
                    args.append(a)
            # simply fire the execute with a subprocess check_call
            # if this returns an error code, raise an exception
            try:
                if len(args)>1:
                    subprocess.Popen(args).wait()
                else:
                    subprocess.Popen(args,shell=True).wait()
            except:
                msg="Failed to execute "+str(args)
                raise PipelineException,PipelineException.value % msg

    ###*************************************************
    def shouldWeFire(self,pname):
        """ Asks through stdin if the user want to fire the program
        returns False for N, True for T. """
        loop=True
        while loop==True:
            sys.stdout.write("Run: %s?[y/n]"%pname)
            l=sys.stdin.readline()
            l=l.rstrip("\n")
            l=l.upper()
            if l=="Y" or l=="N":
                loop=False
        if l=="Y":
            return True
        else:
            return False
###******************************************************###
def usage():
    """ Prints a usage message. """
    print "Usage: ./pipeline.py -c <config.xml> -d -h"
    print "\t -c <provide a config file xml that specifes which program(s)/function(s) to run (mandatory argument)"
    print "\t -d puts the program in debug mode (optional argument)"
    print "\t -h prints this usage message"


###******************************************************###
if __name__=="__main__":
    try:
        opts,args=getopt.getopt(sys.argv[1:],"c:d")
    except getopt.GetoptError:
        # print usage and exit
        usage()
        sys.exit(2)
    debug=False
    ok=False
    for o,a in opts:
        if o == "-d":
            debug=True
        elif o == "-h":
            usage()
            sys.exit(2)
        elif o == "-c":
            configFile = a
            ok = True
    if ok==False:
        usage()
        sys.exit(2)
    p=Pipeline(configFile,debug)
    p.run()
###******************************************************###
