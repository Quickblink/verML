theory VCDim2
  imports Complex_Main AGentleStart
begin
  
term Max
  
definition "mapify f = (\<lambda>x. Some (f x))" (*This should exist somewhere*)
  
definition "allmaps C D = (if C = {} then {} else {m. dom m = C \<and> ran m \<subseteq> D})"  
definition "restrictH H C D = {m\<in>(allmaps C D). \<exists>h\<in>H. m \<subseteq>\<^sub>m h}"
definition "shatters H C D \<longleftrightarrow> allmaps C D = restrictH H C D"

lemma finitemaps: "finite C \<Longrightarrow> finite D \<Longrightarrow> finite (allmaps C D)"
  by (simp add: allmaps_def finite_set_of_finite_maps)

lemma finiteres: "finite C \<Longrightarrow> finite D \<Longrightarrow> finite (restrictH H C D)"
  by (simp add: finitemaps restrictH_def)

lemma "shatters H C D \<longleftrightarrow> (\<forall>m\<in>(allmaps C D).\<exists>h\<in>H. m \<subseteq>\<^sub>m h)" 
  by (smt Collect_cong dom_def dom_empty mem_Collect_eq restrictH_def allmaps_def shatters_def)
  
lemma empty_shatted: "shatters H {} D"
  by (simp add: allmaps_def restrictH_def shatters_def)

locale vcd =
  fixes X :: "'a set"
    and Y :: "'b set"  
  assumes 
      "X \<noteq> {}" 
    and infx: "infinite X"
    and "card Y = 2" (* is never used! *)
begin

definition "VCDim H = (if finite {m. \<exists>C\<subseteq>X. card C = m \<and> shatters H C Y} then Some (Max {m. \<exists>C\<subseteq>X. card C = m \<and> shatters H C Y}) else None)"
(* definition "VCDim H D = (if \<exists>m. (\<forall>C\<subseteq>X. card C > m \<longrightarrow> \<not>shatters H C D) \<and> (\<exists>C2\<subseteq>X. shatters H C2 D) then Some m else None)" *)

definition "growth H m = Max {k. \<exists>C\<subseteq>X. k = card (restrictH H C Y) \<and> card C = m}"

lemma "{k. \<exists>C\<subseteq>X. k = card (restrictH H C Y) \<and> card C = m} \<noteq> {}"
  by (smt Collect_empty_eq_bot bot_empty_eq empty_iff infinite_arbitrarily_large infx)
  
lemma assumes "VCDim H = Some m" 
  shows "(\<exists>C\<subseteq>X. card C = m \<and> shatters H C Y)"
   and noshatter: "\<not>(\<exists>C\<subseteq>X. card C > m \<and> shatters H C Y)"
proof -
  have s1: "m = Max {m. \<exists>C\<subseteq>X. card C = m \<and> shatters H C Y}" using VCDim_def assms
    by (metis (mono_tags, lifting) Collect_cong option.discI option.inject)
  moreover have s2: "finite {m. \<exists>C\<subseteq>X. card C = m \<and> shatters H C Y}" using VCDim_def assms
    by (metis (mono_tags, lifting) Collect_cong option.simps(3))
   moreover have "{m. \<exists>C\<subseteq>X. card C = m \<and> shatters H C Y} \<noteq> {}"
    using empty_shatted by fastforce
  ultimately show "\<exists>C\<subseteq>X. card C = m \<and> shatters H C Y" using Max_in by auto
  show "\<not>(\<exists>C\<subseteq>X. card C > m \<and> shatters H C Y)"
    by (metis (mono_tags, lifting) Max_ge leD mem_Collect_eq s1 s2)
qed
  

(*Equation 6.3*)
lemma eq63: "finite C \<Longrightarrow> card (restrictH H C Y) \<le> card ({B. B\<subseteq>C \<and> shatters H B Y})"
proof (induct rule: finite.induct)
  case emptyI
  then show ?case by (simp add: allmaps_def restrictH_def)
next
  case (insertI A a)
  then show ?case sorry
qed

(*lemma "m>0 \<Longrightarrow> card C = m \<Longrightarrow> card ({B. B\<subseteq>C}) \<le> 2^m"  
proof -
  have "" *)

lemma "finite {k. \<exists>C\<subseteq>X. k = card (restrictH H C Y) \<and> card C = m}" using finiteres oops

lemma assumes "VCDim H = Some d"
      and "m>0"
      and "C\<subseteq>X"
      and "card C = m"
    shows superaux: "card (restrictH H C Y) \<le> sum (\<lambda>x. m choose x) {0..d}"
proof -
  have f3: "finite C" using assms(2,4) card_ge_0_finite by auto
 have "\<forall>B\<subseteq>C. shatters H B Y \<longrightarrow> card B \<le> d" using assms noshatter
    by (meson \<open>C \<subseteq> X\<close> not_le_imp_less order_trans)
  then have f2: "{B. B\<subseteq>C \<and> shatters H B Y} \<subseteq> {B. B\<subseteq>C \<and> card B \<le> d}" by auto
  have f1: "finite {B. B\<subseteq>C \<and> card B \<le> d}" using f3 by auto
  have "card {B. B\<subseteq>C \<and> card B \<le> d} \<le> sum (\<lambda>x. m choose x) {0..d}"
  proof (induction d)
    case 0
    have "{B. B \<subseteq> C \<and> card B \<le> 0} = {{}}"
      using f3 infinite_super by fastforce
    then show ?case by simp
  next
    case (Suc d)
    have "{B. B \<subseteq> C \<and> card B \<le> Suc d} = {B. B \<subseteq> C \<and> card B \<le> d} \<union> {B. B \<subseteq> C \<and> card B = Suc d}" by auto
    moreover have "{B. B \<subseteq> C \<and> card B \<le> d} \<inter> {B. B \<subseteq> C \<and> card B = Suc d} = {}" by auto
    ultimately have "card {B. B \<subseteq> C \<and> card B \<le> Suc d} = card {B. B \<subseteq> C \<and> card B \<le> d} + card {B. B \<subseteq> C \<and> card B = Suc d}" using f1
        by (simp add: f3 card_Un_disjoint)
    then show ?case using f3 by (simp add: n_subsets assms(4) Suc.IH)
  qed
  from this f2 have "card {B. B\<subseteq>C \<and> shatters H B Y} \<le> sum (\<lambda>x. m choose x) {0..d}"
    by (metis (no_types, lifting) card_mono f1 order_trans)
  then show "card (restrictH H C Y) \<le> sum (\<lambda>x. m choose x) {0..d}" using eq63 f3
    by (metis (mono_tags, lifting) Collect_cong dual_order.strict_trans1 neq_iff not_le_imp_less)
qed

(*Sauers Lemma 6.10*)
lemma assumes "VCDim H = Some d"
      and "m>0"
  shows lem610: "growth H m \<le> sum (\<lambda>x. m choose x) {0..d}"
 (* using n_subsets growth_def eq63 noshatter *)
proof -
  have "\<forall>n \<in> {k. \<exists>C\<subseteq>X. k = card (restrictH H C Y) \<and> card C = m}. n \<le> sum (\<lambda>x. m choose x) {0..d}" using superaux assms(1,2)
    by fastforce
  then have "finite {k. \<exists>C\<subseteq>X. k = card (restrictH H C Y) \<and> card C = m}"
    using finite_nat_set_iff_bounded_le by auto
  moreover have "{k. \<exists>C\<subseteq>X. k = card (restrictH H C Y) \<and> card C = m} \<noteq> {}"
  by (smt Collect_empty_eq_bot bot_empty_eq empty_iff infinite_arbitrarily_large infx)
  ultimately have "growth H m \<in> {k. \<exists>C\<subseteq>X. k = card (restrictH H C Y) \<and> card C = m}"
    using Max_in growth_def by auto
  then show ?thesis
    using assms(1) assms(2) vcd.superaux vcd_axioms by fastforce
qed
  


text \<open>Definition of the Prediction Error (2.1). 
    This is the Isabelle way to write: 
      @{text "L\<^sub>D\<^sub>,\<^sub>f(h) =  D({S. f S \<noteq> h S})"} \<close>
definition PredErr :: "'a pmf \<Rightarrow> ('a \<Rightarrow> 'b) \<Rightarrow> ('a \<Rightarrow> 'b) \<Rightarrow> real" where
  "PredErr D f h = measure_pmf.prob D {S. f S \<noteq> h S}" 

lemma PredErr_alt: "PredErr D f h = measure_pmf.prob D {S\<in>set_pmf D.  f S \<noteq> h S}"
  unfolding PredErr_def apply(rule pmf_prob_cong) by (auto simp add: set_pmf_iff) 

text \<open>Definition of the Training Error (2.2). \<close>
definition TrainErr :: " ('c \<Rightarrow> ('a * 'b)) \<Rightarrow> 'c set \<Rightarrow> ('a \<Rightarrow> 'b) \<Rightarrow> real" where
  "TrainErr S I h = sum (\<lambda>i. case (S i) of (x,y) \<Rightarrow> if h x \<noteq> y then 1::real else 0) I / card I"


(* Sample D f, takes a sample x of the distribution D and pairs it with its
    label f x; the result is a distribution on pairs of (x, f x). *)
definition Sample ::"'a pmf \<Rightarrow> ('a \<Rightarrow> 'b) \<Rightarrow> ('a \<times> 'b) pmf" where
  "Sample D f = do {  a \<leftarrow> D;
                      return_pmf (a,f a) }"


(* Samples n D f, generates a distribution of training sets of length n, which are
     independently and identically distribution wrt. to D.  *)
definition Samples :: "nat \<Rightarrow> 'a pmf \<Rightarrow> ('a \<Rightarrow> 'b) \<Rightarrow> ((nat \<Rightarrow> 'a \<times> 'b)) pmf" where
  "Samples n D f = Pi_pmf {0..<n} undefined (\<lambda>_. Sample D f)"


(*Theorem 6.11*)
lemma assumes "set_pmf D \<subseteq> X"
      and "f ` X = Y"
      and "\<delta>\<in>{x.0<x\<and>x<1}"
      and "h\<in>H"
    shows "measure_pmf.prob (Samples m D f) {S. abs(PredErr D f h - TrainErr S {0..<m} h) \<le> (4+sqrt(ln(real(growth (image mapify H) (2*m)))))/(\<delta> * sqrt(2*m))} \<ge> 1 - \<delta>"
  sorry



definition representative :: "('a\<Rightarrow>'b) set \<Rightarrow> (nat \<Rightarrow> 'a \<times> 'b) \<Rightarrow> nat \<Rightarrow> real \<Rightarrow> bool" where
  "representative H S m \<epsilon> \<longleftrightarrow> (\<forall>h\<in>H. (\<forall>D f. set_pmf D \<subseteq> X \<longrightarrow> f ` X = Y \<longrightarrow> abs(PredErr D f h - TrainErr S {0..<m} h) \<le> \<epsilon>))"


definition uniform_convergence :: "('a\<Rightarrow>'b) set \<Rightarrow> bool" where
  "uniform_convergence H  = (\<exists>M::(real \<Rightarrow> real \<Rightarrow> nat). 
            (\<forall>D f. set_pmf D \<subseteq> X \<longrightarrow> f ` X = Y  \<longrightarrow> (\<forall>m. \<forall> \<epsilon> > 0. \<forall>\<delta>\<in>{x.0<x\<and>x<1}. m \<ge> M \<epsilon> \<delta> \<longrightarrow> 
          measure_pmf.prob (Samples m D f) {S. representative H S m \<epsilon>} \<ge> 1 - \<delta>)))"

lemma ln_le_sqrt: "m\<ge>1 \<Longrightarrow> ln m \<le> 2 * sqrt(m)"
  by (metis divide_le_eq linorder_not_less ln_bound ln_sqrt mult.commute not_one_le_zero order.trans real_sqrt_gt_zero zero_less_numeral)


lemma sqrt_le_m: "m\<ge>1 \<Longrightarrow> sqrt(m) \<le> m"
proof -
  have "m\<ge>1 \<Longrightarrow> sqrt(m) \<le> sqrt m * sqrt m"
    by (smt real_mult_le_cancel_iff1 real_sqrt_ge_one semiring_normalization_rules(3)
        semiring_normalization_rules(8))
  also have "m\<ge>1 \<Longrightarrow> sqrt(m)* sqrt(m) \<le> m" by simp
  finally show "m\<ge>1 \<Longrightarrow> sqrt(m) \<le> m" by simp
qed

lemma aux123: "m\<ge>d \<Longrightarrow> sum (\<lambda>x. m choose x) {0..d} \<le> (d+1)*m^d"
   using sum_bounded_above[of "{0..d}" "(\<lambda>x. m choose x)" "m^d"]
   by (smt One_nat_def add.right_neutral add_Suc_right atLeastAtMost_iff binomial_le_pow binomial_n_0 card_atLeastAtMost diff_zero
       le_antisym le_neq_implies_less le_trans less_one nat_le_linear nat_zero_less_power_iff neq0_conv of_nat_id power_increasing_iff)


lemma assumes "VCDim (image mapify H) = Some d"
  shows "uniform_convergence H"
proof -
  (*fix m d :: nat
  assume "d > 0" "m \<ge> d"*)
  fix m ::nat
  assume a1: "2*m>1" "2*m\<ge>d" "d > 0"
  then have f1: "2*m > 0" by auto
  let ?H = "image mapify H"
  from aux123 lem610 assms f1 a1 have f2: "growth ?H (2*m) \<le> (d+1)*(2*m)^d"
    by (meson le_trans)
  have "(4+sqrt(ln(real(growth (image mapify H) (2*m)))))/(\<delta> * sqrt(2*m))
            = 4/(\<delta> * sqrt(2*m)) +sqrt(ln(real(growth (image mapify H) (2*m))))/(\<delta> * sqrt(2*m))"
    by (simp add: add_divide_distrib)

  
 (* then have "sqrt((ln(growth ?H (2*m)))/(2*m)) \<le> sqrt((ln((d+1)*(2*m)^d))/(2*m))"
    by (simp add: divide_right_mono)
  have "ln ((d+1)*(2*m)^d) = ln (d+1) + ln((2*m)^d)" using f1 a1 ln_mult zero_less_power
    by (metis add_gr_0 of_nat_0_less_iff of_nat_mult)
  then have "sqrt((ln((d+1)*(2*m)^d))/(2*m)) = sqrt((ln(d+1)+d*ln(2*m))/(2*m))" using f1
    by (metis ln_realpow of_nat_0_less_iff of_nat_power)
  have "(ln(d+1)+d*ln(2*m))/(2*m) > 0" using a1
    by (smt ln_gt_zero_iff nat_less_real_le nonzero_divide_mult_cancel_left of_nat_0
        of_nat_add zero_less_divide_iff zero_less_one) *)
  assume a12: "growth ?H (2*m) > 1"
  then have "growth ?H (2*m) > 0" by auto
  then have "ln(growth ?H (2*m)) \<le> ln((d+1)*(2*m)^d)" using f2
    by (smt le_eq_less_or_eq ln_le_cancel_iff nat_less_real_le of_nat_0)
  also have "ln ((d+1)*(2*m)^d) = ln (d+1) + d * ln(2*m)" using f1 a1 ln_mult
     by (metis add_gr_0 ln_realpow of_nat_0_less_iff of_nat_mult of_nat_power zero_less_power) 
  also have "(ln(d+1)+d*ln(2*m)) \<le> (ln(d+1)+d*2* sqrt(2*m))"
    using ln_le_sqrt a1 by auto 
  finally have f12: "(ln(growth ?H (2*m)))/(2*m) \<le> (ln(d+1)+d*2* sqrt(2*m))/(2*m)"
    by (simp add: divide_right_mono)
  also have "... \<le> (ln(d+1)+d*2* sqrt(2*m))/sqrt(2*m)" using frac_le sqrt_le_m
    by (smt a1(3) divide_neg_pos f1 ln_gt_zero_iff nat_0_less_mult_iff nat_less_real_le
        of_nat_0 of_nat_1 of_nat_add pos_divide_le_eq real_sqrt_gt_0_iff)
  also have "... = ln(d+1)/sqrt(2*m) + 2*d" using add_divide_distrib
        proof -
          have "real (m + m) \<noteq> 0"
            using a1(1) by linarith
          then have "(ln (real (Suc d)) + real (d + d) * sqrt (real (m + m))) / sqrt (real (m + m)) = real (d + d) + ln (real (Suc d)) / sqrt (real (m + m))"
        by (metis (no_types) add.commute add_divide_eq_if_simps(2) real_sqrt_eq_zero_cancel_iff)
          then show ?thesis
            by (simp add: mult.commute)
        qed 

   finally have "sqrt((ln(growth ?H (2*m)))/(2*m)) \<le> sqrt(ln(d+1)/sqrt(2*m) + 2*d)"
     using real_sqrt_le_iff by blast
   moreover assume ad: "\<delta>>0"
   moreover have "sqrt(ln(real(growth (image mapify H) (2*m))))/(\<delta> * sqrt(2*m))
      = (sqrt(ln(real(growth (image mapify H) (2*m))))/sqrt(2*m))/\<delta>" by simp
   moreover have "(sqrt(ln(real(growth (image mapify H) (2*m))))/sqrt(2*m))
       = sqrt((ln(growth ?H (2*m)))/(2*m))"
    by (simp add: real_sqrt_divide)
   ultimately have f20: "sqrt(ln(real(growth (image mapify H) (2*m))))/(\<delta> * sqrt(2*m))
             \<le>(sqrt(ln(d+1)/sqrt(2*m) + 2*d))/\<delta>"
     by (smt divide_right_mono)
   have f22: "sqrt(ln(d+1)/sqrt(2*m) + 2*d) \<ge> 0" by simp
   assume "(sqrt(ln(d+1)/sqrt(2*m) + 2*d))/\<delta> \<le> \<epsilon>/2"
   from this ad have "(sqrt(ln(d+1)/sqrt(2*m) + 2*d)) \<le> \<epsilon>*\<delta>/2"
     by (simp add: pos_divide_le_eq)
   then have "ln(d+1)/sqrt(2*m) + 2*d \<le> (\<epsilon>*\<delta>/2)^2"
     using sqrt_le_D by blast
   then have "ln(d+1)/sqrt(2*m) \<le> (\<epsilon>*\<delta>/2)^2 - 2*d" by simp
   then have "1/sqrt(2*m) \<le> ((\<epsilon>*\<delta>/2)^2 - 2*d)/ln(d+1)"

   then have "sqrt(2*m)/ln(d+1) \<ge> 1/((\<epsilon>*\<delta>/2)^2 - 2*d)" 
      
  then have "sqrt(ln(real(growth (image mapify H) (2*m))))/(\<delta> * sqrt(2*m)) \<le> \<epsilon> \<longleftrightarrow>
        sqrt(ln(real(growth (image mapify H) (2*m))))/(sqrt(2*m)) \<le> \<epsilon>*\<delta>"


definition ERM :: "('a \<Rightarrow> 'b) set \<Rightarrow> (nat \<Rightarrow> ('a \<times> 'b)) \<Rightarrow> nat \<Rightarrow> ('a \<Rightarrow> 'b) set" where
  "ERM H S n = {h. is_arg_min (TrainErr S {0..<n}) (\<lambda>s. s\<in>H) h}"

definition ERMe :: "('a \<Rightarrow> 'b) set \<Rightarrow> (nat \<Rightarrow> ('a \<times> 'b)) \<Rightarrow> nat \<Rightarrow> ('a \<Rightarrow> 'b)" where
  "ERMe H S n = (SOME h. h\<in> ERM H S n)"

lemma ERM_subset: "ERM H S n \<subseteq> H" 
  by (simp add: is_arg_min_linorder subset_iff ERM_def)

lemma TrainErr_nn: "TrainErr S I h \<ge> 0"
proof -
  have "0 \<le> (\<Sum>i\<in>I. 0::real)" by simp
  also have "\<dots> \<le> (\<Sum>i\<in>I. case S i of (x, y) \<Rightarrow> if h x \<noteq> y then 1 else 0)"
    apply(rule sum_mono) by (simp add: split_beta') 
  finally show ?thesis 
    unfolding TrainErr_def by auto
qed

lemma ERM_0_in: "h' \<in> H \<Longrightarrow> TrainErr S {0..<n} h' = 0 \<Longrightarrow> h' \<in>ERM H S n"
  unfolding ERM_def by (simp add: TrainErr_nn is_arg_min_linorder)


definition PAC_learnable :: "('a\<Rightarrow>'b) set \<Rightarrow> ((nat \<Rightarrow> 'a \<times> 'b) \<Rightarrow> nat \<Rightarrow> ('a \<Rightarrow> 'b)) \<Rightarrow> bool" where
  "PAC_learnable H L = (\<exists>M::(real \<Rightarrow> real \<Rightarrow> nat). 
            (\<forall>D f. set_pmf D \<subseteq> X \<longrightarrow> f ` X = Y \<longrightarrow> (\<exists>h'\<in>H. PredErr D f h' = 0) \<longrightarrow> (\<forall>m. \<forall> \<epsilon> > 0. \<forall>\<delta>\<in>{x.0<x\<and>x<1}. m \<ge> M \<epsilon> \<delta> \<longrightarrow> 
          measure_pmf.prob (Samples m D f) {S. PredErr D f (L S m) \<le> \<epsilon>} \<ge> 1 - \<delta>)))"

lemma assumes "representative H S m \<epsilon>"
          and "S\<in>Samples m D f"
          and "set_pmf D \<subseteq> X"
          and "f ` X = Y"
          and RealizabilityAssumption: "\<exists>h'\<in>H. PredErr D f h' = 0"
        shows reptopred: "PredErr D f (ERMe H S m) \<le> \<epsilon>"
proof -
      from RealizabilityAssumption  
    obtain h' where h'H: "h'\<in>H" and u: "PredErr D f h' = 0" by blast

    from u have "measure_pmf.prob D {S \<in> set_pmf D. f S \<noteq> h' S} = 0" unfolding PredErr_alt .
    with measure_pmf_zero_iff[of D "{S \<in> set_pmf D. f S \<noteq> h' S}"]       
    have correct: "\<And>x. x\<in>set_pmf D \<Longrightarrow> f x = h' x" by blast

 from assms(2) set_Pi_pmf[where A="{0..<m}"]
      have "\<And>i. i\<in>{0..<m} \<Longrightarrow> S i \<in> set_pmf (Sample D f)"
        unfolding Samples_def by auto 

    then have tD: "\<And>i. i\<in>{0..<m} \<Longrightarrow> fst (S i) \<in> set_pmf D \<and> f (fst (S i)) = snd (S i)"
      unfolding Sample_def by fastforce+ 

    have z: "\<And>i. i\<in>{0..<m} \<Longrightarrow> (case S i of (x, y) \<Rightarrow> if h' x \<noteq> y then 1::real else 0) = 0"
    proof -
      fix i assume "i\<in>{0..<m}"
      with tD have i: "fst (S i) \<in> set_pmf D" and ii: "f (fst (S i)) = snd (S i)" by auto
      from i correct  have "f (fst (S i))  = h' (fst (S i))" by auto                
      with ii have "h' (fst (S i)) = snd (S i)" by auto
      then show "(case S i of (x, y) \<Rightarrow> if h' x \<noteq> y then 1::real else 0) = 0"
        by (simp add: prod.case_eq_if)
    qed

    have Th'0: "TrainErr S {0..<m} h' = 0" 
      unfolding TrainErr_def   using z  
      by fastforce

    then have "h' \<in>ERM H S m" using ERM_0_in h'H by auto
    then have "ERMe H S m \<in> ERM H S m" using ERMe_def by (metis some_eq_ex)
    then have "ERMe H S m \<in> H" using ERM_subset by blast     
    moreover have "(\<forall>h\<in>H. (\<forall>D f. set_pmf D \<subseteq> X \<longrightarrow> f ` X = Y \<longrightarrow> abs(PredErr D f h - TrainErr S {0..<m} h) \<le> \<epsilon>))"
      using representative_def assms(1) by blast
    ultimately have "abs(PredErr D f (ERMe H S m) - TrainErr S {0..<m} (ERMe H S m)) \<le> \<epsilon>"
      using assms by auto
    moreover have "TrainErr S {0..<m} (ERMe H S m) = 0" 
        proof -
          have f1: "is_arg_min (TrainErr S {0..<m}) (\<lambda>f. f \<in> H) (ERMe H S m)"
            using ERM_def \<open>ERMe H S m \<in> ERM H S m\<close> by blast
          have f2: "\<forall>r ra. (((ra::real) = r \<or> ra \<in> {}) \<or> \<not> r \<le> ra) \<or> \<not> ra \<le> r"
            by linarith
          have "(0::real) \<notin> {}"
            by blast
          then show ?thesis
        using f2 f1 by (metis ERM_def Th'0 TrainErr_nn \<open>h' \<in> ERM H S m\<close> is_arg_min_linorder mem_Collect_eq)
        qed
     ultimately show ?thesis by auto
qed

lemma subsetlesspmf: "A\<subseteq>B \<Longrightarrow> measure_pmf.prob Q A \<le> measure_pmf.prob Q B"
  using measure_pmf.finite_measure_mono by fastforce

lemma assumes "(\<forall>D f. set_pmf D \<subseteq> X \<longrightarrow> f ` X = Y  \<longrightarrow> (\<forall>m. \<forall> \<epsilon> > 0. \<forall>\<delta>\<in>{x.0<x\<and>x<1}. m \<ge> M \<epsilon> \<delta> \<longrightarrow> 
          measure_pmf.prob (Samples m D f) {S. representative H S m \<epsilon>} \<ge> 1 - \<delta>))"
  shows aux44:"set_pmf D \<subseteq> X \<Longrightarrow> f ` X = Y \<Longrightarrow> (\<exists>h'\<in>H. PredErr D f h' = 0) \<Longrightarrow>  \<epsilon> > 0 \<Longrightarrow> \<delta>\<in>{x.0<x\<and>x<1} \<Longrightarrow> m \<ge> M \<epsilon> \<delta> \<Longrightarrow> 
          measure_pmf.prob (Samples m D f) {S. PredErr D f (ERMe H S m) \<le> \<epsilon>} \<ge> 1 - \<delta>"
  proof -
  fix D f m \<epsilon> \<delta>
  assume a1: "set_pmf D \<subseteq> X" "f ` X = Y" "\<exists>h'\<in>H. PredErr D f h' = 0" "\<epsilon> > 0" "\<delta>\<in>{x.0<x\<and>x<1}" "m \<ge> M \<epsilon> \<delta>"
  from this assms have "measure_pmf.prob (Samples m D f) {S. representative H S m \<epsilon>} \<ge> 1 - \<delta>" by auto
  then have "measure_pmf.prob (Samples m D f) 
  {S. set_pmf D \<subseteq> X \<and> f ` X = Y \<and> (\<exists>h'\<in>H. PredErr D f h' = 0) \<and> (S\<in>Samples m D f) \<and> representative H S m \<epsilon>} \<ge> 1 - \<delta>"
    using a1 by (smt DiffE mem_Collect_eq pmf_prob_cong set_pmf_iff)
  moreover have "{S. set_pmf D \<subseteq> X \<and> f ` X = Y \<and> (\<exists>h'\<in>H. PredErr D f h' = 0) \<and> (S\<in>Samples m D f) \<and> representative H S m \<epsilon>}
        \<subseteq> {S. PredErr D f (ERMe H S m) \<le> \<epsilon>}" using reptopred by blast
  ultimately show "measure_pmf.prob (Samples m D f) {S. PredErr D f (ERMe H S m) \<le> \<epsilon>} \<ge> 1 - \<delta>"
    using subsetlesspmf order_trans by fastforce
qed


(* lemma 4.2*)
lemma assumes "uniform_convergence H"(*"representative H S m (\<epsilon>/2)"*)
    and RealizabilityAssumption: "\<exists>h'\<in>H. PredErr D f h' = 0"
  shows "PAC_learnable H (ERMe H)" 
proof -
  obtain M where f1: "(\<forall>D f. set_pmf D \<subseteq> X \<longrightarrow> f ` X = Y  \<longrightarrow> (\<forall>m. \<forall> \<epsilon> > 0. \<forall>\<delta>\<in>{x.0<x\<and>x<1}. m \<ge> M \<epsilon> \<delta> \<longrightarrow> 
          measure_pmf.prob (Samples m D f) {S. representative H S m \<epsilon>} \<ge> 1 - \<delta>))"
    using assms uniform_convergence_def by auto
  from aux44 f1 have "(\<forall>D f. set_pmf D \<subseteq> X \<longrightarrow> f ` X = Y \<longrightarrow> (\<exists>h'\<in>H. PredErr D f h' = 0) \<longrightarrow> (\<forall>m. \<forall> \<epsilon> > 0. \<forall>\<delta>\<in>{x.0<x\<and>x<1}. m \<ge> M \<epsilon> \<delta> \<longrightarrow> 
          measure_pmf.prob (Samples m D f) {S. PredErr D f (ERMe H S m) \<le> \<epsilon>} \<ge> 1 - \<delta>))"
  by blast
  then show ?thesis using PAC_learnable_def by auto
qed