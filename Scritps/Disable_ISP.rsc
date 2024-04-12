/interface
:local result [/ping 8.8.4.4 count=3]
:if ($result>0) do={
    :log info "Funciona el LINK ISP 1"
    :local rtenable [/ip route print count-only where comment="DEFAULT ROUTE ISP 2" && disabled=yes] 
    :if ($rtenable=1) do={
        :log info "Habilitando el enlace ISP 1"
        [/ip route enable [find comment="DEFAULT ROUTE ISP 2"]]
    }
} else={
    :log error "Enlace caido LINK ISP 1"
    :local rtenable [/ip route print count-only where comment="DEFAULT ROUTE ISP 2" && disabled=no]
    :if ($rtenable=1) do={
        :log error "Deshabilitando el enlace ISP 1"
        [/ip route disable [find comment="DEFAULT ROUTE ISP 2"]]
    }
}