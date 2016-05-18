#!/usr/bin/perl
use lib "/usr/lib/huannet";
use myhuannetDBD qw( :standard );
use myhuannet qw( :standard );
my $executioncondition = $ARGV[0];
my $deletetime;
my %settings;
readhash( "/usr/etc/myhuannet/settings", \%settings );                #读settings生成hash格式
my $agentlogtime    = $settings{'maxbackuptime'};                     #代理日志保留时间
my $devicelogtime   = 7;                                              #设备状态日志保留时间
my $hourtime        = 2;                                              #小时日志保留时间
my $daytime         = 3;                                              #天日志保留时间
my $weektime        = 7;                                              #周日志保留时间
my $monthtime       = 30;                                              #月日志保留时间
my $threemonthstime = 100;                                              #三个月日志保留时间
my $halfyeartime    = 180;                                              #半年日志保留时间
if( @ARGV != 1 ) {                                                    #命令行参数个数不为一 
	print "You need to input an argument \nUseage: logrotate.pl -applog | -flowlog | -devicelog\n";
	exit;
}
elsif ( $executioncondition eq '-h'  ) {
    print "Useage: logrotate.pl -applog | -flowlog | -devicelog\n";
    exit;
}
elsif ( $executioncondition eq '-applog' ) {
    my @huannetdatabases = &getHuannetDB();  
    #print @huannetdatabases;                                         #获取huannet_数据库
    chomp @huannetdatabases;
    foreach my $huannetdatabase (@huannetdatabases) {
        &OpenSQL($huannetdatabase);
        my @timenamehuannet = ( "dg_log", "mail_log", "messages_log", "proxy_log" );
        my %tablescolums = ( "dg_log" => "login,datetime,hostip,url,action",
                             "mail_log" => "hostip,mailfrom,mailto,subject,direction,type,datetime,size,hasattach,path,login",
                             "messages_log" => "datetime,hostip,protocolname,outgoing,type,localid,remoteid,filtered,evendata,login",
                             "proxy_log" => "login,datetime,hostip,size,url,mime,title"
                            );
        my $a = 0;
        for ( 0 .. $#timenamehuannet ) {
            my $filecolums = $tablescolums{ $timenamehuannet[$a] };
            my $wherefile1 = "where datetime <= unix_timestamp()-86400*$agentlogtime";
            my $dbsql1 = "select $filecolums from $timenamehuannet[$a] $wherefile1 into outfile '$timenamehuannet[$a]' fields terminated by ','";
            my $dbsql2 = "delete from $timenamehuannet[$a] $wherefile1";
            &exesql($dbsql1);    
            &exesql ($dbsql2);                                       #删除过期日志
            if ( -e "/huannet/log/$huannetdatabase" ) {               #判断目录是否存在
                print "exist\n";
                &createtempfile( $huannetdatabase, $timenamehuannet[$a] );
            }
            else {
                print "createdir\n";
                `mkdir -p /huannet/log/$huannetdatabase`;
                &createtempfile( $huannetdatabase, $timenamehuannet[$a] );
            }
            $a++;
        }
    }
    &CloseSQL();                                                      #执行完断开数据库连接
}
elsif ( $executioncondition eq '-flowlog' ) {
    my @huannetdatabases = &getHuannetDB();                           #获取huannet_数据库
    chomp @huannetdatabases;
    foreach my $huannetdatabase (@huannetdatabases) {
    	  print "$huannetdatabase\n";
        &OpenSQL($huannetdatabase);
        my @timenamehuannet1 = (
            "hour_flow_app",               "hour_flow_if_app",
            "hour_flow_if_proto",          "hour_flow_interface",
            "hour_flow_proto",             "hour_flow_user",
            "day_flow_app",                "day_flow_if_app",
            "day_flow_if_proto",           "day_flow_interface",
            "day_flow_ip",                 "day_flow_ip_app",
            "day_flow_ip_proto",           "day_flow_proto",
            "day_flow_user",               "week_flow_app",
            "week_flow_if_app",            "week_flow_if_proto",
            "week_flow_interface",         "week_flow_ip",
            "week_flow_ip_app",            "week_flow_ip_proto",
            "week_flow_proto",             "week_flow_user",
            "month_flow_app",              "month_flow_if_app",
            "month_flow_if_proto",         "month_flow_interface",
            "month_flow_ip",               "month_flow_ip_app",
            "month_flow_ip_proto",         "month_flow_proto",
            "month_flow_user",             "three_months_flow_app",
            "three_months_flow_if_app",    "three_months_flow_if_proto",
            "three_months_flow_interface", "three_months_flow_ip",
            "three_months_flow_ip_app",    "three_months_flow_ip_proto",
            "three_months_flow_proto",     "three_months_flow_user",
            "half_year_flow_app",          "half_year_flow_if_app",
            "half_year_flow_if_proto",     "half_year_flow_interface",
            "half_year_flow_ip",           "half_year_flow_ip_app",
            "half_year_flow_ip_proto",     "half_year_flow_proto",
            "half_year_flow_user"
                                );
        foreach my $timenamehuannet1 (@timenamehuannet1) {
            if ( $timenamehuannet1 =~ /^hour/ ) {
                $deletetime = $hourtime;
                print "$deletetime\n";
            }
            elsif ( $timenamehuannet1 =~ /^day/ ) {
                $deletetime = $daytime;
                print "$deletetime\n";
            }
            elsif ( $timenamehuannet1 =~ /^week/ ) {
                $deletetime = $weektime;
                print "$deletetime\n";
            }
            elsif ( $timenamehuannet1 =~ /^month/ ) {
                $deletetime = $monthtime;
                print "$deletetime\n";
            }
            elsif ( $timenamehuannet1 =~ /^three_months/ ) {
                $deletetime = $threemonthstime;
                print "$deletetime\n";
            }
            elsif ( $timenamehuannet1 =~ /^half_year/ ) {
                $deletetime = $halfyeartime;
                print "$deletetime\n";
            }
        	  my $wherefile2 = "where datetime <= unix_timestamp()-86400*$deletetime";
        	  my $dbsql3 = "delete from $timenamehuannet1 $wherefile2";
            &exesql ($dbsql3);                                        #删除过期日志
        }
    }
    &CloseSQL();                                                      #执行完断开数据库连接 
}
elsif ( $executioncondition eq '-devicelog' ) {
    print my $bbb = `date +%s`;
    &openMhDB();
    my @timenamehuannet = (
        "mh_os_infodetail", "mh_dl_version",
        "mh_dl_netcard",    "mh_os_service",
        "mh_os_info"
                           );
    my %tablescolums = (
        "mh_os_infodetail" => "id_dlid,id_Connections,id_OnlineKnowUsers,id_OnlineUnknowUsers,id_loadavg1,id_loadavg5,id_loadavg15,id_cpuproportion,id_cputop,id_memproportion,id_memtop,id_memCache,id_ImportTime,id_OpTime",
        "mh_dl_version" => "v_dlid,v_vtid,v_Version,v_UpdateTime",
        "mh_dl_netcard" => "nc_dlid,nc_interface,nc_driver,nc_isconnected,nc_netmode,nc_assignstatus,nc_mac,nc_ImportTime,nc_OpTime",
        "mh_os_service" => "s_dlid,s_UsingName,s_RuningTime,s_ImportTime,s_OpTime",
        "mh_os_info" => "i_dlid,i_InputType,i_NetType,i_UpSpeed,i_DownSpeed,i_TotalFlux,i_OnlineTime,i_ImportTime,i_OpTime"
                        );
    my $a = 0;
    for ( 0 .. $#timenamehuannet ) { 
    	  my $timename;
    	  my $filecolums = $tablescolums{ $timenamehuannet[$a] };
        if ( $a == 0 ) {
            $timename = "id_ImportTime";
        }
        elsif ( $a == 1 ) {
            $timename = "v_UpdateTime";
        }
        elsif ( $a == 2 ) {
            $timename = "nc_ImportTime";
        }
        elsif ( $a == 3 ) {
            $timename = "s_ImportTime";
        }
        elsif ( $a == 4 ) {
            $timename = "i_ImportTime";
        }
        my $wherefile1 = "where '$timename' <= unix_timestamp()-86400*$devicelogtime";
        my $dbsql1 = "select $filecolums from $timenamehuannet[$a] $wherefile1 into outfile '$timenamehuannet[$a]' fields terminated by ','";
        my $dbsql2 = "delete from $timenamehuannet[$a] $wherefile1";
        #print "$dbsql1\n";
        &exesqlMhDB($dbsql1);    
        print "$dbsql2\n";
        &exesqlMhDB ($dbsql2);                                       #删除过期日志
        if ( -e "/huannet/log/myhuannet" ) {                          #判断目录是否存在
            &createtempfile( myhuannet, $timenamehuannet[$a] );
        }
        else {
            print "createdir\n";
            `mkdir -p /huannet/log/myhuannet`;
            &createtempfile( myhuannet, $timenamehuannet[$a] );
        }
        $a++;
    }
    print my $ccc = `date +%s`;
    print my $eee = $ccc - $bbb;
    &closeMhDB();
}
else {
    print "You input a wrong argument!\nUse -h for help\n";
    exit;
}


sub createtempfile {
    my ( $machinedatabasename, $tablelogname ) = @_;
    my $temppath1 = "/opt/lampp/var/mysql/$machinedatabasename/$tablelogname";
    my $temppath2 = "/huannet/log/$machinedatabasename/$tablelogname";
    open( FILE, "$temppath1" )
      or die "Couldn't open $temppath1:$!";                           #创建文件并写入
    my @data = <FILE>;
    close(FILE);
    `rm -f /opt/lampp/var/mysql/$machinedatabasename/$tablelogname`;
    open( FILE, ">>$temppath2" ) or die "Couldn't open $temppath2:$!";
    foreach my $data (@data) {
        chomp $data;                                                  #去掉换行符
        print FILE "$data\n";
    }
    close(FILE);                                                      #执行完关闭文件
}
