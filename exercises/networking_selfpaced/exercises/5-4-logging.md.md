https://github.com/colin-mccarthy/ansible-playbooks-for-cisco-ios/blob/master/intent_logging

<b>Recommendation:</b> Nipper recommends that Syslog and Buffered logging be configured on rtr1. Logging can be enabled with the following command:<br>
&nbsp;<br>
<div class="command">logging on</div><br>
&nbsp;<br>
To configure Syslog logging, four things need to be set; a source interface for the Syslog messages to be sent from, one or more Syslog hosts to send messages to, the Syslog logging mes
sage severity level and the Syslog facility. The following commands can be used to configure Syslog logging:<br>
&nbsp;<br>
<div class="command">logging source-interface {<i>Interface</i>}</div>&nbsp;<br>
<div class="command">logging host {<i>Syslog IP address or hostname</i>}</div>&nbsp;<br>
<div class="command">logging trap {<i>Logging message severity level</i>}</div>&nbsp;<br>
<div class="command">logging facility {<i>Syslog facility</i>}</div><br>
&nbsp;<br>
Buffered logging can be configured with the following command:<br>
&nbsp;<br>
<div class="command">logging buffered {<i>Buffer Size</i>} {<i>Logging message severity level</i>}</div><br>
&nbsp;<br>

<!--stackedit_data:
eyJoaXN0b3J5IjpbMTcxNTkwMDMzMl19
-->