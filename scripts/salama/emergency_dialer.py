#!/usr/bin/env python
 
'''
single_command.py - execute a single command over ESL
'''
from optparse import OptionParser
import sys
from xml.etree import ElementTree
import ESL
import logging
logging.basicConfig(filename='caller-log.log',level=logging.DEBUG)

def find_between( s, first, last ):
    try:
        start = s.index( first ) + len( first )
        end = s.index( last, start )
        return s[start:end]
    except ValueError:
        return ""

 
def main(argv):
    parser = OptionParser()
    parser.add_option('-a', '--auth', dest='auth', default='ClueCon',
                      help='ESL password')
    parser.add_option('-s', '--server', dest='server', default='127.0.0.1',
                      help='FreeSWITCH server IP address')
    parser.add_option('-p', '--port', dest='port', default='8021',
                      help='FreeSWITCH server event socket port')
    parser.add_option('-c', '--command', dest='command', default='status',
                      help='command to run, surround multi-word commands in ""s')
 
    (options, args) = parser.parse_args()
 
    con = ESL.ESLconnection(options.server, options.port, options.auth)
 
    if not con.connected():
        logging.debug('Not Connected')
        sys.exit(2)

    e = con.api(options.command)
    if e:
        logging.debug(e.getBody())
        userID = sys.argv[1]
        toBeContacted = sys.argv[2]
        userExtension = sys.argv[3]
        logging.debug(userID)
        logging.debug(toBeContacted)
        logging.debug(userExtension)
        emergencyContacts = toBeContacted.split(',')
        for user in emergencyContacts:
            dialString = str('originate {contact=' + user + ',userExtension=' + userExtension + ',userID=' + userID + '}sofia/internal/' + user + '@127.0.0.1:5062 113')
            logging.debug(dialString)
            con.api(dialString)
 
 
if __name__ == '__main__':
    main(sys.argv[1:])