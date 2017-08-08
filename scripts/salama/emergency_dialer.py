#!/usr/bin/env python
 
'''
single_command.py - execute a single command over ESL
'''
from optparse import OptionParser
import sys
from xml.etree import ElementTree
import ESL


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
        print 'Not Connected'
        sys.exit(2)

    e = con.api(options.command)
    if e:
        print e.getBody()
        userID = sys.argv[1]
        toBeContacted = sys.argv[2]
        userExtension = sys.argv[3]
        print(userID)
        print(toBeContacted)
        print(userExtension)
        emergencyContacts = toBeContacted.split(',')
        for user in emergencyContacts:
            print(user)
            registrationXML = con.api('sofia xmlstatus profile internal reg')
            registeredUsers = ElementTree.fromstring(registrationXML.getBody())
            for registration in registeredUsers[0]:
                contact = registration.find('sip-auth-user').text
                sip = registration.find('contact').text
                print(sip)
                if user == contact:
                    startString = '"" <sip:'
                    endString = ';'
                    sipString = find_between(sip, startString, endString)
                    dialString = str('originate {contact=' + contact + ',userExtension=' + userExtension + ',userID=' + userID + '}sofia/internal/' + sipString + ' 113')
                    print(dialString)
                    con.api(dialString)
 
 
if __name__ == '__main__':
    main(sys.argv[1:])