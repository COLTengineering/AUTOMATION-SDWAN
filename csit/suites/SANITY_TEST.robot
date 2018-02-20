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
CHECK WAN INTERFACE.
    [Tags]    sanity
    ${lan_dict}    Get Interface Status    ${cpe2_connection_id}    intf_name=${cpe2_data['MPLS_WAN_INTERFACE']}
    Should Be Equal    ${lan_dict['ADMIN']}    ${status_up}
    Should Be Equal    ${lan_dict['OPER']}    ${status_up}
    Should Be Equal    ${lan_dict['IP']}    ${cpe2_data['MPLS_WAN_INTERFACE_IP']}
    ${lan_dict}    Get Interface Status    ${cpe2_connection_id}    intf_name=${cpe2_data['INTERNET_WAN_INTERFACE']}
    Should Be Equal    ${lan_dict['ADMIN']}    ${status_up}
    Should Be Equal    ${lan_dict['OPER']}    ${status_up}
    Should Be Equal    ${lan_dict['IP']}    ${cpe2_data['INTERNET_WAN_INTERFACE_IP']}

CHECK LAN INTERFACE.
    ${lan_dict}    Get Interface Status    ${cpe2_connection_id}    intf_name=${cpe2_data['LAN1_INTERFACE']}
    Should Be Equal    ${lan_dict['ADMIN']}    up
    Should Be Equal    ${lan_dict['OPER']}    up
    Should Be Equal    ${lan_dict['IP']}    ${cpe2_data['LAN1_INTERFACE_IP_WITH_MASK']}
    ${lan_dict}    Get Interface Status    ${cpe2_connection_id}    intf_name=${cpe2_data['LAN2_INTERFACE']}
    Should Be Equal    ${lan_dict['ADMIN']}    up
    Should Be Equal    ${lan_dict['OPER']}    up
    Should Be Equal    ${lan_dict['IP']}    ${cpe2_data['LAN2_INTERFACE_IP']}

CHECK IPSEC SA.
    ${sa_dict}    get ipsec sa    ${cpe2_connection_id}    org=${cpe2_data['ORG_NAME']}    vpn_profile=${cpe2_data['WC1_VPN_PROFILE']}
    LOG TO CONSOLE    ${sa_dict}
    Dictionary Should Contain Key    ${sa_dict}    ${cpe2_data['WC1_VXLAN_IP']}    msg= ${cpe2_data['WC1_VXLAN_IP']} IPSEC SA is NOT exist

CHECK BGP NEIGHBOR.
    ${neighbr_dict}    Get Bgp Neighbor    ${cpe2_connection_id}    org=${cpe2_data['ORG_NAME']}
    LOG TO CONSOLE    ${neighbr_dict}
    Dictionary Should Contain Key    ${neighbr_dict}    ${cpe2_data['BGP_NBR_IP']}    msg= ${cpe2_data['BGP_NBR_IP']} NBR is NOT exist
    ${Value}=    Get From Dictionary    ${neighbr_dict}    ${cpe2_data['BGP_NBR_IP']}
    Log To Console    ${Value[1]}
    Should Be Equal    ${Value[1]}    ${established}    BGP session not established
    Should Not Be Equal    ${Value[2]}    ${zero}    Prefix not recieved
    Should Not Be Equal    ${Value[3]}    ${zero}    Prefix not sent

CHECK BGP ROUTE .
    [Tags]    check
    ${routes_list}    get route    ${cpe2_connection_id}    routing_instance=${routing_instances[0]}    protocol=${protocols[0]}
    Should Not Be Empty    ${routes_list}    msg=route list is empty
    LOG TO CONSOLE    ${routes_list}
    ${result}=    check route    ${routes_list}    dest_address=${cpe1_data['LAN1_ROUTE']}    next_hop=${cpe1_data['ESP_IP']}    intf_name=${indirect}
    Should Be True    ${result}    msg=route not present
