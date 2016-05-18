
#!/usr/bin/perl

#统计字符出现次数 并排序


print ("\t统计字符出现次数\n请输入英文字符：回车ctl+d 结束输入：\n");
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
    #print ("调用第[".++$i."]次:$a=>$lettercount{$a} $b=>$lettercount{$b}\n");
    $lettercount{$a}<=>$lettercount{$b};
}
print ("\n原始哈希表元素列表 ：\n");
while (($key, $var) = each(%lettercount)) {
  print ("$key=>$var\n");
}
print ("\n哈希表按字符排序：\n");
foreach $word (sort keys(%lettercount)) {
    print ("$word=>$lettercount{$word}\n");
    }
print("\n按字符出现次数排序\n");
foreach $word (reverse sort occurrences(sort keys(%lettercount))) {
        print ("$word=>$lettercount{$word}\n");
    }