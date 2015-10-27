# usage: change the sample*.txt, then just paste this whole file into PowerShell prompt


get-childitem *.txt | % {

$infile = $_.basename + $_.extension;
$outfile = $_.basename + '-masked.txt';

$sep = '|';
# column number for the different attributes. first column is 0. 
$usrid = 0;
$nric = 1;
$name = 2;
$fname = 3;
$lname = 4;
$spmail = 6;
$persMail = 7;
$address = 36;
$tel2 = 39;
$mobile = 40;


# the below columns will be blanked out completely
#$toBlankOut = 30, 33, 35, 37, 41, 42, 43, 44, 45 # these columns were blank in Zhiquan's sample masked file
$toBlankOut = 30, 37, 39, 40, 41 # 30 = gmail, 37 = studentAddr2, 39 = tel2, 40 = mobile, 41 = photo


cat $infile | %{ 
    $currline = '';
    $currUsrId = ''; 
    $colnum = 0;
    $_.Split($sep)| %{ 
        $currcol = $_;
        
        if ($colnum -ne 0) { $currline += '|' }
       
        if ($currcol.length -eq 0) {
            #do nothing and bypass all elseifs
        } 
        elseif ($colnum -eq $usrid){
            $currUsrId = $currcol;
        } 
        elseif ($toBlankOut -contains $colnum){
            $currcol = '';
        } 
        elseif ($colnum -eq $nric){
            # we will mask NRIC.
            # e.g. student with id = P5678, NRIC = S1234G 
            # will get masked NRIC = S5678G

            $nricSuffix = $currcol[$currcol.length-1]
            $currcol = 'S'  + $currUsrId.substring(1) + $nricSuffix
        }
        elseif ($colnum -eq $name -or $colnum -eq $fname -or $colnum -eq $lname){
            # e.g. name = Lee Ah Kow 
            # will get masked to Lxx Axx Kxx

            $maskedName = ''
            $myctr = 0;
            $currcol.split(' ') | %{
                if($myctr -ne 0){ $maskedName += ' '}
                $maskedName += $_[0]
                for($i = 1; $i -lt $_.length; $i++){
                    $maskedName += 'x'
                }    
                $myctr++            
            }
            $currcol = $maskedName
        }
        elseif ($colnum -eq $spmail){
            # e.g. ahkow42@ichat.sp.edu.sg becomes P5678@ichat.sp.edu.sg
            $emailSuffix = $currcol.split('@')[1]
            $currcol = $currUsrId + '@' + $emailSuffix
        }
        elseif ($colnum -eq $persMail){
            # we will change e.g. id = P5678, persMail = hello@gmail.com
            # to p5678@ncstestmail.com
            $currcol = $currUsrId + '@ncstestmail.com'
        }
        elseif ($colnum -eq $address){
            # we will change to mask all letters to x and all digits to y            
            $currcol = $currcol -replace '[a-zA-Z]', 'x' -replace '[0-9]','y'
        } 
        elseif ($colnum -eq $tel2 -or $colnum -eq $mobile){
            # 98765432 becomes 99995432
            $currcol = '9999' + $currcol.Substring(4)
        } 
      
        $currline += $currcol
        $colnum++
    }; 
    $currline
} > $outfile
#cat $infile
#cat $outfile
}