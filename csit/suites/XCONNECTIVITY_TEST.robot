*** Settings ***
Documentation     A test suite with tests for SDWAN LAN conenctivity.
...               Topology:-
...               ____________________________
...               | VersaDirector |
...               |___________________________|
...               |
...               |
...               |
...               _____________|_______________
...               | WanCtrller1 |
...               |____________________________|
...               | |
...               | |
...               | |
...               INTERNET/MPLS
...               | |
...               | |___
...               ______|__ ___|___
...               | | | |
...               LAN1--+ CPE1 | | CPE2 +--LAN1
...               |________| |_______|
...
...
...               Testplan Goals:-
...               1. CHECK IF IP ADDRESS IS SET AND INTERFACE IS UP.
Suite Setup       Start_Suite
Suite Teardown    Stop_Suite
Metadata          Version    1.0\nMore Info For more information about Robot Framework see http://robotframework.org\nAuthor Sathishkumar murugesan\nDate 12 Dec 2017\nExecuted At HOST\nTest Framework Robot Framework Python
Variables         ../Topology/devices.py
Variables         ../Variables/SANITY/Variables.py
Library           Collections
Library           String
Library           ../libraries/Connect_devices.py
Library           ../libraries/Commands.py
Resource          ../libraries/Resource.robot

*** Test Cases ***
CHECK BGP ROUTE .
    [Tags]    check
    ${routes_list}    get route    ${cpe2_connection_id}    routing_instance=${routing_instances[0]}    protocol=${protocols[0]}
    Should Not Be Empty    ${routes_list}    msg=route list is empty
    LOG TO CONSOLE    ${routes_list}
    ${result}=    check route    ${routes_list}    dest_address=${cpe1_data['LAN1_ROUTE']}    next_hop=${cpe1_data['ESP_IP']}    intf_name=${indirect}
    Should Be True    ${result}    msg=route not present

CHECK PING TO CPE1
    ${result}=    Ping    ${cpe2_connection_id}    ${cpe1_data['LAN1_INTERFACE_IP']}    source=${cpe2_data['LAN1_INTERFACE_IP']}    routing_instance=${routing_instances[0]}
    Should Be True    ${result}    msg=Ping failed.

MAKE MPLS WAN INTERFACE DOWN and ping CPE1
    config commands    ${cpe2_connection_id}    ${cmd1}
    ${result}=    Ping    ${cpe2_connection_id}    ${cpe1_data['LAN1_INTERFACE_IP']}    source=${cpe2_data['LAN1_INTERFACE_IP']}    routing_instance=${routing_instances[0]}
    Should Be True    ${result}    msg=Ping failed.

MAKE MPLS WAN INTERFACE UP and ping CPE1.
    config commands    ${cpe2_connection_id}    ${cmd2}
    ${result}=    Ping    ${cpe2_connection_id}    ${cpe1_data['LAN1_INTERFACE_IP']}    source=${cpe2_data['LAN1_INTERFACE_IP']}    routing_instance=${routing_instances[0]}
    Should Be True    ${result}    msg=Ping failed.

MAKE INERNET WAN INTERFACE DOWN ang ping CPE1.
    config commands    ${cpe2_connection_id}    ${cmd3}
    ${result}=    Ping    ${cpe2_connection_id}    ${cpe1_data['LAN1_INTERFACE_IP']}    source=${cpe2_data['LAN1_INTERFACE_IP']}    routing_instance=${routing_instances[0]}
    Should Be True    ${result}    msg=Ping failed.


MAKE INTERNET WAN INTERFACE UP and ping CPE1.
    config commands    ${cpe2_connection_id}    ${cmd4}
    ${result}=    Ping    ${cpe2_connection_id}    ${cpe1_data['LAN1_INTERFACE_IP']}    source=${cpe2_data['LAN1_INTERFACE_IP']}    routing_instance=${routing_instances[0]}
    #    LOG TO CONSOLE    ${result}
    Should Be True    ${result}    msg=Ping failed.



