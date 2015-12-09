#! /usr/bin/perl -w

use strict;
use DBI;

# program to manually add all original PDB cluster assignments

# ---------- DECLARATION OF GLOBAL VARIABLES ----------

my $H1file = "H1_Clusters_Assignments.txt";
my $H2file = "H2_Clusters_Assignments.txt";
my $L1file = "L1_Clusters_Assignments.txt";
my $L2file = "L2_Clusters_Assignments.txt";
my $L3file = "L3_Clusters_Assignments.txt";

# ---------- END OF GLOBAL VARIABLES DECLARATION SECTION ----------

# ---------- SUB ROUTINES ----------  

# ---------- END OF SUB ROUTINES ----------

unless (open H1CLUSTERFILE, '+>'.$H1file) {

die "\nCannot open folder $H1file!\n";
exit;

}

print H1CLUSTERFILE "H1 1acy_1 3/12A\n";
print H1CLUSTERFILE "H1 1baf_1 2/11A\n";
print H1CLUSTERFILE "H1 1bbd_1 1/10A\n";
print H1CLUSTERFILE "H1 1bbj_1 1/10A\n";
print H1CLUSTERFILE "H1 1cgs_1 1/10A\n";
print H1CLUSTERFILE "H1 1dbb_1 1/10A\n";
print H1CLUSTERFILE "H1 1dfb_1 1/10A\n";
print H1CLUSTERFILE "H1 1eap_1 ?/10A\n";
print H1CLUSTERFILE "H1 1fai_1 1/10A\n";
print H1CLUSTERFILE "H1 1fbi_1 ?/10A\n";
print H1CLUSTERFILE "H1 1fgv_1 1/10A\n";
print H1CLUSTERFILE "H1 1fig_1 ?/10D\n";
print H1CLUSTERFILE "H1 1for_1 1/10A\n";
print H1CLUSTERFILE "H1 1fpt_1 1/10A\n";
print H1CLUSTERFILE "H1 1frg_1 1/10A\n";
print H1CLUSTERFILE "H1 1fvc_1 1/10A\n";
print H1CLUSTERFILE "H1 1fvd_1 1/10A\n";
print H1CLUSTERFILE "H1 1ggi_1 ?/10A\n";
print H1CLUSTERFILE "H1 1gig_1 1/10A\n";
print H1CLUSTERFILE "H1 1hil_1 1/10A\n";
print H1CLUSTERFILE "H1 1ibg_1 1/10A\n";
print H1CLUSTERFILE "H1 1igc_1 1/10A\n";
print H1CLUSTERFILE "H1 1igf_1 1/10A\n";
print H1CLUSTERFILE "H1 1igi_1 ?/10B\n";
print H1CLUSTERFILE "H1 1igm_1 1/10A\n";
print H1CLUSTERFILE "H1 1ikf_1 1/10A\n";
print H1CLUSTERFILE "H1 1ind_1 ?/10A\n";
print H1CLUSTERFILE "H1 1jel_1 1/10A\n";
print H1CLUSTERFILE "H1 1jhl_1 1/10A\n";
print H1CLUSTERFILE "H1 1lmk_1 1/10A\n";
print H1CLUSTERFILE "H1 1mam_1 1/10A\n";
print H1CLUSTERFILE "H1 1mcp_1 1/10A\n";
print H1CLUSTERFILE "H1 1mfa_1 1/10A\n";
print H1CLUSTERFILE "H1 1mlb_1 1/10A\n";
print H1CLUSTERFILE "H1 1nbv_1 ?/10C\n";
print H1CLUSTERFILE "H1 1ncb_1 1/10A\n";
print H1CLUSTERFILE "H1 1rmf_1 1/10A\n";
print H1CLUSTERFILE "H1 1tet_1 1/10A\n";
print H1CLUSTERFILE "H1 1vfa_1 1/10A\n";
print H1CLUSTERFILE "H1 2cgr_1 1/10A\n";
print H1CLUSTERFILE "H1 2fb4_1 1/10A\n";
print H1CLUSTERFILE "H1 2fbj_1 1/10A\n";
print H1CLUSTERFILE "H1 2gfb_1 1/10A\n";
print H1CLUSTERFILE "H1 2hfl_1 1/10A\n";
print H1CLUSTERFILE "H1 3hfm_1 1/10A\n";
print H1CLUSTERFILE "H1 4fab_1 1/10A\n";
print H1CLUSTERFILE "H1 6fab_1 1/10A\n";
print H1CLUSTERFILE "H1 7fab_1 1/10A\n";
print H1CLUSTERFILE "H1 8fab_1 1/10A\n";

close H1CLUSTERFILE;

unless (open H2CLUSTERFILE, '+>'.$H2file) {

die "\nCannot open folder $H2file!\n";
exit;

}

print H2CLUSTERFILE "H2 1acy_1 1/9A\n";
print H2CLUSTERFILE "H2 1baf_1 1/9A\n";
print H2CLUSTERFILE "H2 1bbd_1 2/10A\n";
print H2CLUSTERFILE "H2 1bbj_1 ?/10C\n";
print H2CLUSTERFILE "H2 1cgs_1 2/10A\n";
print H2CLUSTERFILE "H2 1dbb_1 ?/10A\n";
print H2CLUSTERFILE "H2 1dfb_1 3/10B\n";
print H2CLUSTERFILE "H2 1eap_1 2/10A\n";
print H2CLUSTERFILE "H2 1fai_1 2/10A\n";
print H2CLUSTERFILE "H2 1fbi_1 2/10A\n";
print H2CLUSTERFILE "H2 1fgv_1 2/10A\n";
print H2CLUSTERFILE "H2 1fig_1 ?/10F\n";
print H2CLUSTERFILE "H2 1for_1 2/10A\n";
print H2CLUSTERFILE "H2 1fpt_1 2/10A\n";
print H2CLUSTERFILE "H2 1frg_1 3/10B\n";
print H2CLUSTERFILE "H2 1fvc_1 2/10A\n";
print H2CLUSTERFILE "H2 1fvd_1 2/10A\n";
print H2CLUSTERFILE "H2 1ggi_1 1/9A\n";
print H2CLUSTERFILE "H2 1gig_1 1/9A\n";
print H2CLUSTERFILE "H2 1hil_1 3/10B\n";
print H2CLUSTERFILE "H2 1ibg_1 1/9A\n";
print H2CLUSTERFILE "H2 1igc_1 3/10B\n";
print H2CLUSTERFILE "H2 1igf_1 3/10B\n";
print H2CLUSTERFILE "H2 1igi_1 2/10A\n";
print H2CLUSTERFILE "H2 1igm_1 3/10B\n";
print H2CLUSTERFILE "H2 1ikf_1 3/10B\n";
print H2CLUSTERFILE "H2 1ind_1 ?/10C\n";
print H2CLUSTERFILE "H2 1jel_1 2/10A\n";
print H2CLUSTERFILE "H2 1jhl_1 2/10A\n";
print H2CLUSTERFILE "H2 1lmk_1 2/10A\n";
print H2CLUSTERFILE "H2 1mam_1 4/12A\n";
print H2CLUSTERFILE "H2 1mcp_1 4/12A\n";
print H2CLUSTERFILE "H2 1mfa_1 2/10A\n";
print H2CLUSTERFILE "H2 1mlb_1 2/10A\n";
print H2CLUSTERFILE "H2 1nbv_1 ?/12B\n";
print H2CLUSTERFILE "H2 1ncb_1 4/10A\n";
print H2CLUSTERFILE "H2 1rmf_1 ?/10D\n";
print H2CLUSTERFILE "H2 1tet_1 2/10A\n";
print H2CLUSTERFILE "H2 1vfa_1 1/9A\n";
print H2CLUSTERFILE "H2 2cgr_1 2/10A\n";
print H2CLUSTERFILE "H2 2fb4_1 3/10B\n";
print H2CLUSTERFILE "H2 2fbj_1 3/10B\n";
print H2CLUSTERFILE "H2 2gfb_1 3/10B\n";
print H2CLUSTERFILE "H2 2hfl_1 2/10A\n";
print H2CLUSTERFILE "H2 3hfm_1 1/9A\n";
print H2CLUSTERFILE "H2 4fab_1 ?/12B\n";
print H2CLUSTERFILE "H2 6fab_1 ?/10E\n";
print H2CLUSTERFILE "H2 7fab_1 1/9A\n";
print H2CLUSTERFILE "H2 8fab_1 3/10B\n";

close H2CLUSTERFILE;

unless (open L1CLUSTERFILE, '+>'.$L1file) {

die "\nCannot open folder $L1file!\n";
exit;

}

print L1CLUSTERFILE "L1 1acy_1 ?/15B\n";
print L1CLUSTERFILE "L1 1baf_1 1/10A\n";
print L1CLUSTERFILE "L1 1bbd_1 3/17A\n";
print L1CLUSTERFILE "L1 1bbj_1 2/11A\n";
print L1CLUSTERFILE "L1 1cgs_1 ?/16A\n";
print L1CLUSTERFILE "L1 1dbb_1 4/16A\n";
print L1CLUSTERFILE "L1 1dfb_1 2/11A\n";
print L1CLUSTERFILE "L1 1eap_1 ?/11A\n";
print L1CLUSTERFILE "L1 1fai_1 2/11A\n";
print L1CLUSTERFILE "L1 1fbi_1 2/11A\n";
print L1CLUSTERFILE "L1 1fgv_1 2/11A\n";
print L1CLUSTERFILE "L1 1fig_1 6/12A\n";
print L1CLUSTERFILE "L1 1for_1 1/10A\n";
print L1CLUSTERFILE "L1 1fpt_1 4/16A\n";
print L1CLUSTERFILE "L1 1frg_1 3/17A\n";
print L1CLUSTERFILE "L1 1fvc_1 ?/11A\n";
print L1CLUSTERFILE "L1 1fvd_1 ?/11A\n";
print L1CLUSTERFILE "L1 1ggi_1 5/15A\n";
print L1CLUSTERFILE "L1 1gig_1 7l/14B\n";
print L1CLUSTERFILE "L1 1hil_1 3/17A\n";
print L1CLUSTERFILE "L1 1ibg_1 ?/15B\n";
print L1CLUSTERFILE "L1 1igc_1 ?/11A\n";
print L1CLUSTERFILE "L1 1igf_1 ?/16A\n";
print L1CLUSTERFILE "L1 1igi_1 4/16A\n";
print L1CLUSTERFILE "L1 1igm_1 2/11A\n";
print L1CLUSTERFILE "L1 1ikf_1 2/11A\n";
print L1CLUSTERFILE "L1 1ind_1 7l/14B\n";
print L1CLUSTERFILE "L1 1jel_1 ?/16C\n";
print L1CLUSTERFILE "L1 1jhl_1 2/11A\n";
print L1CLUSTERFILE "L1 1lmk_1 ?/16A\n";
print L1CLUSTERFILE "L1 1mam_1 2/11A\n";
print L1CLUSTERFILE "L1 1mcp_1 3/17A\n";
print L1CLUSTERFILE "L1 1mfa_1 7l/14B\n";
print L1CLUSTERFILE "L1 1mlb_1 2/11A\n";
print L1CLUSTERFILE "L1 1nbv_1 ?/16B\n";
print L1CLUSTERFILE "L1 1ncb_1 ?/11A\n";
print L1CLUSTERFILE "L1 1rmf_1 4/16A\n";
print L1CLUSTERFILE "L1 1tet_1 ?/16A\n";
print L1CLUSTERFILE "L1 1vfa_1 2/11A\n";
print L1CLUSTERFILE "L1 2cgr_1 ?/16A\n";
print L1CLUSTERFILE "L1 2fb4_1 5l/13A\n";
print L1CLUSTERFILE "L1 2fbj_1 1/10A\n";
print L1CLUSTERFILE "L1 2gfb_1 2/11A\n";
print L1CLUSTERFILE "L1 2hfl_1 1/10A\n";
print L1CLUSTERFILE "L1 3hfm_1 2/11A\n";
print L1CLUSTERFILE "L1 4fab_1 ?/16B\n";
print L1CLUSTERFILE "L1 6fab_1 2/11A\n";
print L1CLUSTERFILE "L1 7fab_1 6l/14A\n";
print L1CLUSTERFILE "L1 8fab_1 ?/11B\n";

close L1CLUSTERFILE;

unless (open L2CLUSTERFILE, '+>'.$L2file) {

die "\nCannot open folder $L2file!\n";
exit;

}

print L2CLUSTERFILE "L2 1acy_1 1/7A\n";
print L2CLUSTERFILE "L2 1baf_1 1/7A\n";
print L2CLUSTERFILE "L2 1bbd_1 1/7A\n";
print L2CLUSTERFILE "L2 1bbj_1 1/7A\n";
print L2CLUSTERFILE "L2 1cgs_1 1/7A\n";
print L2CLUSTERFILE "L2 1dbb_1 ?/7A\n";
print L2CLUSTERFILE "L2 1dfb_1 1/7A\n";
print L2CLUSTERFILE "L2 1eap_1 1/7A\n";
print L2CLUSTERFILE "L2 1fai_1 1/7A\n";
print L2CLUSTERFILE "L2 1fbi_1 1/7A\n";
print L2CLUSTERFILE "L2 1fgv_1 1/7A\n";
print L2CLUSTERFILE "L2 1fig_1 1/7A\n";
print L2CLUSTERFILE "L2 1for_1 1/7A\n";
print L2CLUSTERFILE "L2 1fpt_1 1/7A\n";
print L2CLUSTERFILE "L2 1frg_1 1/7A\n";
print L2CLUSTERFILE "L2 1fvc_1 1/7A\n";
print L2CLUSTERFILE "L2 1fvd_1 1/7A\n";
print L2CLUSTERFILE "L2 1ggi_1 1/7A\n";
print L2CLUSTERFILE "L2 1gig_1 1/7A\n";
print L2CLUSTERFILE "L2 1hil_1 1/7A\n";
print L2CLUSTERFILE "L2 1ibg_1 1/7A\n";
print L2CLUSTERFILE "L2 1igc_1 1/7A\n";
print L2CLUSTERFILE "L2 1igf_1 1/7A\n";
print L2CLUSTERFILE "L2 1igi_1 1/7A\n";
print L2CLUSTERFILE "L2 1igm_1 1/7A\n";
print L2CLUSTERFILE "L2 1ikf_1 1/7A\n";
print L2CLUSTERFILE "L2 1ind_1 1/7A\n";
print L2CLUSTERFILE "L2 1jel_1 1/7A\n";
print L2CLUSTERFILE "L2 1jhl_1 1/7A\n";
print L2CLUSTERFILE "L2 1lmk_1 1/7A\n";
print L2CLUSTERFILE "L2 1mam_1 1/7A\n";
print L2CLUSTERFILE "L2 1mcp_1 1/7A\n";
print L2CLUSTERFILE "L2 1mfa_1 1/7A\n";
print L2CLUSTERFILE "L2 1mlb_1 1/7A\n";
print L2CLUSTERFILE "L2 1nbv_1 1/7A\n";
print L2CLUSTERFILE "L2 1ncb_1 1/7A\n";
print L2CLUSTERFILE "L2 1rmf_1 1/7A\n";
print L2CLUSTERFILE "L2 1tet_1 1/7A\n";
print L2CLUSTERFILE "L2 1vfa_1 1/7A\n";
print L2CLUSTERFILE "L2 2cgr_1 1/7A\n";
print L2CLUSTERFILE "L2 2fb4_1 1/7A\n";
print L2CLUSTERFILE "L2 2fbj_1 1/7A\n";
print L2CLUSTERFILE "L2 2gfb_1 1/7A\n";
print L2CLUSTERFILE "L2 2hfl_1 1/7A\n";
print L2CLUSTERFILE "L2 3hfm_1 1/7A\n";
print L2CLUSTERFILE "L2 4fab_1 1/7A\n";
print L2CLUSTERFILE "L2 6fab_1 ?/7B\n";
print L2CLUSTERFILE "L2 7fab_1 ?/?\n";
print L2CLUSTERFILE "L2 8fab_1 ?/7A\n";

close L2CLUSTERFILE;

unless (open L3CLUSTERFILE, '+>'.$L3file) {

die "\nCannot open folder $L3file!\n";
exit;

}

print L3CLUSTERFILE "L3 1acy_1 1/9A\n";
print L3CLUSTERFILE "L3 1baf_1 5/10A\n";
print L3CLUSTERFILE "L3 1bbd_1 1/9A\n";
print L3CLUSTERFILE "L3 1bbj_1 1/9A\n";
print L3CLUSTERFILE "L3 1cgs_1 1/9A\n";
print L3CLUSTERFILE "L3 1dbb_1 1/9A\n";
print L3CLUSTERFILE "L3 1dfb_1 4/7A\n";
print L3CLUSTERFILE "L3 1eap_1 ?/8B\n";
print L3CLUSTERFILE "L3 1fai_1 1/9A\n";
print L3CLUSTERFILE "L3 1fbi_1 1/9A\n";
print L3CLUSTERFILE "L3 1fgv_1 1/9A\n";
print L3CLUSTERFILE "L3 1fig_1 ?/9E\n";
print L3CLUSTERFILE "L3 1for_1 1/9A\n";
print L3CLUSTERFILE "L3 1fpt_1 1/9A\n";
print L3CLUSTERFILE "L3 1frg_1 1/9A\n";
print L3CLUSTERFILE "L3 1fvc_1 1/9A\n";
print L3CLUSTERFILE "L3 1fvd_1 1/9A\n";
print L3CLUSTERFILE "L3 1ggi_1 1/9A\n";
print L3CLUSTERFILE "L3 1gig_1 ?/9D\n";
print L3CLUSTERFILE "L3 1hil_1 1/9A\n";
print L3CLUSTERFILE "L3 1ibg_1 1/9A\n";
print L3CLUSTERFILE "L3 1igc_1 1/9A\n";
print L3CLUSTERFILE "L3 1igf_1 1/9A\n";
print L3CLUSTERFILE "L3 1igi_1 1/9A\n";
print L3CLUSTERFILE "L3 1igm_1 1/9A\n";
print L3CLUSTERFILE "L3 1ikf_1 1/9A\n";
print L3CLUSTERFILE "L3 1ind_1 1/9A\n";
print L3CLUSTERFILE "L3 1jel_1 ?/9D\n";
print L3CLUSTERFILE "L3 1jhl_1 1/9A\n";
print L3CLUSTERFILE "L3 1lmk_1 1/9A\n";
print L3CLUSTERFILE "L3 1mam_1 1/9A\n";
print L3CLUSTERFILE "L3 1mcp_1 1/9A\n";
print L3CLUSTERFILE "L3 1mfa_1 ?/9C\n";
print L3CLUSTERFILE "L3 1mlb_1 1/9A\n";
print L3CLUSTERFILE "L3 1nbv_1 1/9A\n";
print L3CLUSTERFILE "L3 1ncb_1 1/9A\n";
print L3CLUSTERFILE "L3 1rmf_1 1/9A\n";
print L3CLUSTERFILE "L3 1tet_1 1/9A\n";
print L3CLUSTERFILE "L3 1vfa_1 1/9A\n";
print L3CLUSTERFILE "L3 2cgr_1 1/9A\n";
print L3CLUSTERFILE "L3 2fb4_1 5l/11A\n";
print L3CLUSTERFILE "L3 2fbj_1 2/9B\n";
print L3CLUSTERFILE "L3 2gfb_1 1/9A\n";
print L3CLUSTERFILE "L3 2hfl_1 3/8A\n";
print L3CLUSTERFILE "L3 3hfm_1 1/9A\n";
print L3CLUSTERFILE "L3 4fab_1 1/9A\n";
print L3CLUSTERFILE "L3 6fab_1 1/9A\n";
print L3CLUSTERFILE "L3 7fab_1 4l/9C\n";
print L3CLUSTERFILE "L3 8fab_1 ?/9F\n";

close L3CLUSTERFILE;


