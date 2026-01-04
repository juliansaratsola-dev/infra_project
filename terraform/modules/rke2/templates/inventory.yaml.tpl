# Installation Inventory
servers:
%{ for ip in server_ips ~}
  - ${ip}
%{ endfor ~}

agents:
%{ for ip in agent_ips ~}
  - ${ip}
%{ endfor ~}
