set term off
store set &__DIR_TEMP.\sqlenv replace
set term on
set lines 120
col host_name for a15
col instance_name for a10
col startup_time for a18
col user for a12
col version for a10
col status for a10
select decode(instr(host_name,'.'),0,host_name,
       substr(host_name,1,instr(host_name,'.')-1)) host_name,
       instance_name,d.name dbname, user,
       i.status,to_char(startup_time, 'dd/mm/yy hh24:mi:ss') startup_time,
       version, logins, d.open_mode
from v$instance i, v$database d;

@&__DIR_TEMP.\sqlenv
set term on
