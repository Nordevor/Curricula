#!/usr/bin/perl -w

use strict;
use File::Path qw(make_path);
use Lib::Common;
use Cwd;

$Common::command = shift or Util::halt("There is no command to process (i.e. AREA-INST)");
# pending
my %list_of_areas  = ();

# ok
sub gen_batch($$)
{
		Util::precondition("read_institutions_list");
		my ($source,$target) = (@_);
		my $txt = Util::read_file($source);

		#print "institution=$Common::institution\n";
		$txt =~ s/<INST>/$Common::institution/g;
		my $filter = $Common::inst_list{$Common::institution}{filter};
		$txt =~ s/<FILTER>/$filter/g;
		$txt =~ s/<VERSION>/$Common::inst_list{$Common::institution}{version}/g;
		$txt =~ s/<AREA>/$Common::inst_list{$Common::institution}{area}/g;
		my $output_bib_dir = Common::get_template("OutputBinDir");
		$txt =~ s/<OUTBIN>/$output_bib_dir/g;

		my $InDir = Common::get_template("InDir");
		$txt =~ s/<IN_DIR>/$InDir/g;

		my $InTexDir = Common::get_template("InTexDir");
		$txt =~ s/<IN_TEX_DIR>/$InTexDir/g;

		my $InInstDir = Common::get_template("InInstDir");
		$txt =~ s/<IN_INST_DIR>/$InInstDir/g;

		my $OutputDir = Common::get_template("OutDir");
		$txt =~ s/<OUTPUT_DIR>/$OutputDir/g;

		my $OutputInstDir = Common::get_template("OutputInstDir");
		$txt =~ s/<OUTPUT_INST_DIR>/$OutputInstDir/g;

		my $OutputLogDir = Common::get_template("OutputLogDir");
		$txt =~ s/<OUT_LOG_DIR>/$OutputLogDir/g;

		my $OutputTexDir = Common::get_template("OutputTexDir");
		$txt =~ s/<OUTPUT_TEX_DIR>/$OutputTexDir/g;

		my $OutputDotDir = Common::get_template("OutputDotDir");
		$txt =~ s/<OUTPUT_DOT_DIR>/$OutputDotDir/g;

		my $OutputFigDir = Common::get_template("OutputFigDir");
		$txt =~ s/<OUTPUT_FIG_DIR>/$OutputFigDir/g;

		my $OutputScriptsDir = Common::get_template("OutputScriptsDir");
		$txt =~ s/<OUTPUT_SCRIPTS_DIR>/$OutputScriptsDir/g;

		my $OutputHtmlDir = Common::get_template("OutputHtmlDir");
		$txt =~ s/<OUTPUT_HTML_DIR>/$OutputHtmlDir/g;

		my $OutputCurriculaHtmlFile = Common::get_template("output-curricula-html-file");
		$txt =~ s/<OUTPUT_CURRICULA_HTML_FILE>/$OutputCurriculaHtmlFile/g;

		my $OutputIndexHtmlFile = Common::get_template("output-index-html-file");
		$txt =~ s/<OUTPUT_INDEX_HTML_FILE>/$OutputIndexHtmlFile/g;

		my $UnifiedMain = Common::get_template("unified-main-file");
		$UnifiedMain =~ m/(.*)\.tex/;
		$UnifiedMain = $1;
		$txt =~ s/<UNIFIED_MAIN_FILE>/$UnifiedMain/g;

		my $MainFile = Common::get_template("curricula-main");
		$MainFile =~ m/(.*)\.tex/;
		$MainFile = $1;
		$txt =~ s/<MAIN_FILE>/$MainFile/g;

		my $country_without_accents = Common::get_template("country_without_accents");
		$txt =~ s/<COUNTRY>/$country_without_accents/g;

		my $language_without_accents = Common::get_template("language_without_accents");
		$txt =~ s/<LANG>/$language_without_accents/g;

		my $InLangBaseDir = Common::get_template("InLangBaseDir");
		$txt =~ s/<IN_LANG_BASE_DIR>/$InLangBaseDir/g;

		my $InLangDir = Common::get_template("InLangDir");
		$txt =~ s/<IN_LANG_DIR>/$InLangDir/g;

		$txt =~ s/<HTML_FOOTNOTE>/$Common::config{HTMLFootnote}/g;

		$txt =~ s/<SEM_ACAD>/$Common::config{Semester}/g;
		$txt =~ s/<PLAN>/$Common::config{Plan}/g;
		$txt =~ s/<FIRST_SEM>/$Common::config{SemMin}/g;
		$txt =~ s/<LAST_SEM>/$Common::config{SemMax}/g;

		$txt =~ s/<PLAN>/$Common::config{Plan}/g;

		Util::write_file($target, $txt);
		Util::print_message("gen_batch: $target created successfully ...");
		system("chmod 774 $target");
		#foreach my $inst (sort keys %inst_list)
		#{	print "[[$inst]] ";	}
}

# ok
sub gen_compileall_script()
{
	Util::precondition("read_institutions_list");
	my $compileall_file = Common::get_template("out-compileall-file");
	open(OUT, ">$compileall_file") or Util::halt("gen_compileall_script: $compileall_file does not open");
	print OUT "#!/bin/csh\n\n";
	my $body = "";
	my $rm_list = "";
	foreach my $inst (sort keys %Common::inst_list)
	{
		#print "($inst)";
		print OUT "rm -rf html/$Common::inst_list{$inst}{area}-$inst $Common::inst_list{$inst}{area}-$inst-big-main.*\n";
		$body    .= "./scripts/updatelog.pl \"$inst: Starting compilation ...\"\n";
		#$body   .= "set fecha = `date`\n";
		#$body   .= "./scripts/updatelog.pl \"$fecha\"\n";  ``
		$body    .= "./compile  $Common::inst_list{$inst}{area}-$inst \n";
		$body    .= "./gen-html $Common::inst_list{$inst}{area}-$inst\n\n";
	}
	#print OUT "rm -rf html";
	print OUT "\n$body";
	close(OUT);
	system("chmod 774 $compileall_file");
	Util::print_message("gen_compileall_script ok");
}

# ok
sub generate_institution()
{
	Util::precondition("read_institutions_list");
	my $current_inst_file = Common::get_template("out-current-institution-file");

        my $output_txt = "";
	$output_txt .= "% This file was generated by gen-scripts.pl ... DO NOT TOUCH !!!\n";
	$output_txt .= "\\newcommand{\\currentinstitution}{$Common::institution}\n";
	$output_txt .= "\\newcommand{\\siglas}{\\currentinstitution}\n";
	my $area = $Common::inst_list{$Common::institution}{area};
	$output_txt .= "\\newcommand{\\currentarea}{$area}\n";
	$output_txt .= "\\newcommand{\\CountryWithoutAccents}{$Common::config{country_without_accents}}\n";
	$output_txt .= "\\newcommand{\\Country}{$Common::config{country}}\n";
	$output_txt .= "\\newcommand{\\LanguageWithoutAccent}{$Common::config{language_without_accents}}\n";
	$output_txt .= "\n";

	$output_txt .= "\\newcommand{\\basedir}{".getcwd()."}\n";
	$output_txt .= "\\newcommand{\\InDir}{\\basedir/".Common::get_template("InDir")."}\n";
	$output_txt .= "\\newcommand{\\InLangBaseDir}{\\basedir/".Common::get_template("InLangBaseDir")."}\n";
	$output_txt .= "\\newcommand{\\InLangDir}{\\basedir/".Common::get_template("InLangDir")."}\n";
	$output_txt .= "\\newcommand{\\InAllTexDir}{\\basedir/".Common::get_template("InAllTexDir")."}\n";
	$output_txt .= "\\newcommand{\\InTexDir}{\\basedir/".Common::get_template("InTexDir")."}\n";
	$output_txt .= "\\newcommand{\\InStyDir}{\\basedir/".Common::get_template("InStyDir")."}\n";
	$output_txt .= "\\newcommand{\\InTexAllDir}{\\basedir/".Common::get_template("InTexAllDir")."}\n";
        $output_txt .= "\\newcommand{\\InStyAllDir}{\\basedir/".Common::get_template("InStyAllDir")."}\n";

	$output_txt .= "\\newcommand{\\InCountryDir}{\\basedir/".Common::get_template("InCountryDir")."}\n";
	$output_txt .= "\\newcommand{\\InCountryTexDir}{\\basedir/".Common::get_template("InCountryTexDir")."}\n";
	$output_txt .= "\\newcommand{\\InSPCDir}{\\basedir/".Common::get_template("InCountryDir")."/$Common::config{discipline}/$Common::config{area}/SPC}\n";
 	$output_txt .= "\\newcommand{\\InInstDir}{\\basedir/".Common::get_template("InInstDir")."}\n";
	$output_txt .= "\\newcommand{\\InLogosDir}{\\basedir/".Common::get_template("InLogosDir")."}\n";

	$output_txt .= "\\newcommand{\\OutputTexDir}{\\basedir/".Common::get_template("OutputTexDir")."}\n";
 	$output_txt .= "\\newcommand{\\OutputFigDir}{\\basedir/".Common::get_template("OutputFigDir")."}\n";
 	$output_txt .= "\\newcommand{\\InSyllabiBaseDir}{\\basedir/".Common::get_template("InSyllabiContainerDir")."}\n";
 	$output_txt .= "\\newcommand{\\OutputPrereqDir}{\\basedir/".Common::get_template("OutputPrereqDir")."}\n";
 	$output_txt .= "\n";

	$output_txt .= "\\newcommand{\\TeamTitle}{$Common::config{dictionary}{TeamTitle}}\n";
	$output_txt .= "\\newcommand{\\FinalReport}{$Common::config{dictionary}{FinalReport}}\n";
	$output_txt .= "\\newcommand{\\LastModification}{$Common::config{dictionary}{LastModification}}\n";
	$output_txt .= "\\newcommand{\\BibliographySection}{$Common::config{dictionary}{BibliographySection}}\n";

	$output_txt .= "\\newcommand{\\PeopleDir}{\\basedir/$Common::config{InPeopleDir}}\n";

	Util::write_file($current_inst_file, $output_txt);
	my $output_current_institution = Common::get_template("OutDir")."/tex/current-institution.tex";

	Util::print_message("Creating: $output_current_institution ...");
	Util::write_file($output_current_institution, $output_txt);
	Util::print_message("generate_institution ok");
}

# ok
sub update_acronyms()
{
	Util::precondition("read_institutions_list");
	my $txt = "";
	my $inst_info_root = Common::get_template("InCountryDir");
	my $out_txt = "";
	foreach my $inst (sort keys %Common::inst_list)
	{
		#system("mv institutions-info/institutions-$inst.tex institutions-info/info-$inst.tex");
		my $out_txt_name = Common::GetInstitutionInfo($Common::inst_list{$inst}{country}, $Common::config{discipline}, $Common::config{area}, $inst);
		if(-e $out_txt_name)
		{
            Util::print_message("Reading: $out_txt_name ...");
			$out_txt = Util::read_file($out_txt_name);
			if($out_txt =~ m/\\newcommand\{\\University\}\{(.*?)\}/)
			{
				my $univ = $1;
				$univ =~ s/\\xspace//g;
				$txt .= "\\acro{$inst}{$univ}\n";
			}
		}
        else
        {
                        Util::print_message("File: \"$out_txt_name\" does not exist ...");
        }
	}
	#print "$basetex/$area-acronyms.tex\n";
	my $acronym_base = Common::get_template("in-acronyms-base-file");
	   $out_txt 		 = Util::read_file($acronym_base);

	if($out_txt =~ m/%--LIST-OF-INSTITUTIONS--/)
	{
		my $pretxt = "\n%Text generated by gen-scripts.pl ... DO NOT TOUCH !!!\n";
		my $postxt = "%End of text generated\n";
		$out_txt =~ s/%--LIST-OF-INSTITUTIONS--/$pretxt$txt$postxt/g;
	}

	my $out_acronym_file = Common::get_template("out-acronym-file");
	Util::write_file($out_acronym_file, $out_txt);
	Util::print_message("update_acronyms ($out_acronym_file) OK!");
}

sub gen_batch_files()
{
	my $file = "";
	my ($input, $output) = ("", "");
	foreach my $file ("compile1institucion", "gen-html-1institution")
	{
	    system("rm $file*");
	    system("rm ".Common::get_template("out-$file-file"));
	    $input     = Common::get_template("in-$file-base-file");
	    $output    = Common::get_template("out-$file-file");
	    gen_batch($input, $output);
	    Util::print_message("Creating shorcut: ln -s $output");
	    system("cp $output .");
	}
	foreach my $file ("gen-eps-files", "gen-graph", "gen-book", "CompileTexFile", "compile-simple-latex")
	{
	    system("rm ".Common::get_template("out-$file-file"));
	    $input     = Common::get_template("in-$file-base-file");
	    $output    = Common::get_template("out-$file-file");
	    gen_batch($input, $output);
	}
	my $command = "cp ". Common::get_template("preamble0-file")." ". Common::get_template("OutputTexDir");
	Util::print_message($command);
	system($command);
}

sub main()
{
	Common::set_initial_configuration($Common::command);
	gen_batch_files();
	gen_compileall_script();
	generate_institution();
	update_acronyms();
	Util::print_message("End gen-scripts ...\n");
}

main();
