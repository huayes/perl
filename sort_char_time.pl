
#!/usr/bin/perl

#ͳ���ַ����ִ��� ������


print ("\tͳ���ַ����ִ���\n������Ӣ���ַ����س�ctl+d �������룺\n");
while ($line = <STDIN>){
    
    $line =~ tr/A-Z/a-z/;
    $line =~ s/[^a-z]//g;
    @letters=split(//,$line);
    foreach $letter (@letters){
        $lettercount{$letter}+=1;
    }
}
$i=0;
sub occurrences{
    #print ("���õ�[".++$i."]��:$a=>$lettercount{$a} $b=>$lettercount{$b}\n");
    $lettercount{$a}<=>$lettercount{$b};
}
print ("\nԭʼ��ϣ��Ԫ���б� ��\n");
while (($key, $var) = each(%lettercount)) {
  print ("$key=>$var\n");
}
print ("\n��ϣ���ַ�����\n");
foreach $word (sort keys(%lettercount)) {
    print ("$word=>$lettercount{$word}\n");
    }
print("\n���ַ����ִ�������\n");
foreach $word (reverse sort occurrences(sort keys(%lettercount))) {
        print ("$word=>$lettercount{$word}\n");
    }