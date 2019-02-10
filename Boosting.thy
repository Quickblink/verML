theory Boosting
  imports Complex_Main LinearPredictor
begin

lemma only_one: "a\<in>A \<Longrightarrow> \<forall>b\<in>A. b = a \<Longrightarrow> card A = 1"
  by (metis (no_types, hide_lams) One_nat_def card.empty card_Suc_eq empty_iff equalityI insert_iff subsetI) 


locale BOOST =
  fixes C :: "'a set"
    and y :: "'a \<Rightarrow> real"
    and oh :: "('a \<Rightarrow> real) \<Rightarrow> 'a \<Rightarrow> real"
  assumes 
       nonemptyx: "C \<noteq> {}"
    and finitex: "finite C"
    and ytwoclass: "\<forall>x. y x \<in> {-1,1}"
    and ohtwoclass: "\<forall>Ds x. oh Ds x \<in> {-1,1}"
begin




lemma cardxgtz:"card C > 0"
  by (simp add: card_gt_0_iff finitex nonemptyx) 



fun h :: "nat \<Rightarrow> 'a \<Rightarrow> real"
and \<epsilon> :: "nat \<Rightarrow> real"
and w :: "nat \<Rightarrow> real"
and D :: "nat \<Rightarrow> 'a \<Rightarrow> real" where
    "h t i = oh (\<lambda>x. D t x) i"
  | "\<epsilon> t = sum (\<lambda>x. D t x) {x\<in>C. h t x \<noteq> y x}"
  | "w t = (ln (1/(\<epsilon> t)-1))/2"
  | "D (Suc t) i = (D t i * exp (-(w t)*(h t i)*(y i))) / (sum (\<lambda>x. D t x * exp (-(w t)*(h t x)*(y x))) C)"
  | "D 0 i = 1/(card C)"

lemma ctov: "h t x = y x \<Longrightarrow> h t x * y x = 1" and ctov2: "h t x \<noteq> y x \<Longrightarrow> h t x * y x = -1"
  apply (smt empty_iff insert_iff mult_cancel_left2 mult_minus_right ytwoclass)
  by (metis empty_iff h.simps insert_iff mult.commute mult.left_neutral ohtwoclass ytwoclass)
    
  
fun f :: "nat \<Rightarrow> 'a \<Rightarrow> real" where
  "f (Suc t) i = (w t) * (h t i) + f t i"
|"f 0 i = 0"

lemma aux34: "movec.vec_nth (movec.vec_lambda (\<lambda>t. if t < k then w t else 0))
        = (\<lambda>t. (if t < k then w t else 0))" using vec_lambda_inverse lt_valid[of k w]
    by auto

lemma aux35: "movec.vec_nth (movec.vec_lambda (\<lambda>t. if t < k then h t i else 0))
        = (\<lambda>t. (if t < k then h t i else 0))" using vec_lambda_inverse lt_valid[of k "(\<lambda>t. h t i)"]
    by auto

definition "hyp k i = (f k i > 0)"

lemma convert_f: "(\<lambda>i. f k i > 0)  = (\<lambda>i. (linear_predictor (vec_lambda (\<lambda>t. (if t<k then w t else 0))) 
                                                 (vec_lambda (\<lambda>t. (if t<k then h t i else 0)))))"
proof -
  from aux34 have "\<forall>i. {q. movec.vec_nth (movec.vec_lambda (\<lambda>t. if t < k then w t else 0)) q \<noteq> 0 
        \<and> movec.vec_nth (vec_lambda (\<lambda>t. (if t<k then h t i else 0))) q \<noteq> 0} \<subseteq> {..<k}"
    by auto
  then have "\<forall>i. minner (movec.vec_lambda (\<lambda>t. if t < k then w t else 0))
               (vec_lambda (\<lambda>t. (if t<k then h t i else 0)))
             = (\<Sum>ia\<in>{..<k}.
                 movec.vec_nth (movec.vec_lambda (\<lambda>t. if t < k then w t else 0)) ia \<bullet>
                 movec.vec_nth (vec_lambda (\<lambda>t. (if t<k then h t i else 0))) ia)"
    using minner_alt by auto
  moreover have "\<forall>i. (\<Sum>ia\<in>{..<k}.
                 movec.vec_nth (movec.vec_lambda (\<lambda>t. if t < k then w t else 0)) ia \<bullet>
                 movec.vec_nth (vec_lambda (\<lambda>t. (if t<k then h t i else 0))) ia) = f k i"
    unfolding aux34 aux35 
    apply(induction k)
    by auto
  ultimately show ?thesis unfolding linear_predictor_def by auto
qed

    
    
lemma "linear_predictor (vec_lambda (\<lambda>t. (if t<k then w t else 0))) \<in> all_linear(myroom k)"
  using all_linear_def aux34 myroom_def by auto



lemma "finite M1 \<Longrightarrow> finite M2 \<Longrightarrow> card ((\<lambda>(m1,m2). m1 \<circ>\<^sub>m m2) ` (M1 \<times> M2)) \<le> card M1 * card M2"
  using card_image_le finite_cartesian_product card_cartesian_product
  by (metis Sigma_cong)


lemma "card ({vm. (\<forall>t<k. \<exists>m\<in>Hb. \<forall>x. vec_nth (vm (x::'a)) t = m x) \<and> (\<forall>t\<ge>k. \<forall>x. vec_nth (vm x) t = 0) }) = card Hb ^ k"
proof(induct k)
  case 0
  obtain f::"('a\<Rightarrow>movec)" where o1: "\<forall>x. f x = 0" by fastforce
  then have s1: "f\<in>{vm. (\<forall>t<0. \<exists>m\<in>Hb. \<forall>x. movec.vec_nth (vm x) t = m x) \<and> (\<forall>t\<ge>0. \<forall>x. movec.vec_nth (vm x) t = 0)}"
    by simp 
  have "\<forall>g\<in>{vm. (\<forall>t<0. \<exists>m\<in>Hb. \<forall>x. movec.vec_nth (vm x) t = m x) \<and> (\<forall>t\<ge>0. \<forall>x. movec.vec_nth (vm x) t = 0)}.  \<forall>x. g x = 0"
    using movec_eq_iff by auto
  then have "\<forall>g\<in>{vm. (\<forall>t<0. \<exists>m\<in>Hb. \<forall>x. movec.vec_nth (vm x) t = m x) \<and> (\<forall>t\<ge>0. \<forall>x. movec.vec_nth (vm x) t = 0)}.  g = f"
    using o1 by auto
  then have "card {vm. (\<forall>t<0. \<exists>m\<in>Hb. \<forall>x. movec.vec_nth (vm x) t = m x) \<and> (\<forall>t\<ge>0. \<forall>x. movec.vec_nth (vm x) t = 0)} = 1"
    using s1 by (simp add: only_one)  
  then show ?case by auto 
next
  case (Suc k)
  have "{vm. (\<forall>t<Suc k. \<exists>m\<in>Hb. \<forall>x. movec.vec_nth (vm x) t = m x) \<and> (\<forall>t\<ge>Suc k. \<forall>x. movec.vec_nth (vm x) t = 0)} \<subseteq>
     (\<lambda>(vm, g). (\<lambda>x. upd_movec (vm x) k (g x))) ` ({vm. (\<forall>t<k. \<exists>m\<in>Hb. \<forall>x. movec.vec_nth (vm x) t = m x) \<and> (\<forall>t\<ge>k. \<forall>x. movec.vec_nth (vm x) t = 0)} \<times> Hb)"
  proof (auto)
    fix vm
    assume a1: "\<forall>t<Suc k. \<exists>m\<in>Hb. \<forall>xa. movec.vec_nth (vm xa) t = m xa"
            "\<forall>t\<ge>Suc k. \<forall>xa. movec.vec_nth (vm xa) t = 0"
    let ?kM = "{vm. (\<forall>t<k. \<exists>m\<in>Hb. \<forall>x. movec.vec_nth (vm x) t = m x) \<and> (\<forall>t\<ge>k. \<forall>x. movec.vec_nth (vm x) t = 0)}"
    let ?wm = "(\<lambda>x. upd_movec (vm x) k 0)"
    have "?wm\<in>?kM" sorry
    obtain h where o1: "h\<in>Hb" "\<forall>x. vec_nth (vm x) k = h x" using a1 by auto

    have "\<exists>wm\<in>{vm. (\<forall>t<k. \<exists>m\<in>Hb. \<forall>x. movec.vec_nth (vm x) t = m x) \<and> (\<forall>t\<ge>k. \<forall>x. movec.vec_nth (vm x) t = 0)}. \<exists>h\<in>Hb.
   vm = (\<lambda>(vm, g) x. movec.vec_lambda (\<lambda>k'. if k' = k then g x else movec.vec_nth (vm x) k')) (wm, h)"
      sorry
    then show "vm \<in> (\<lambda>(vm, g) x. movec.vec_lambda (\<lambda>k'. if k' = k then g x else movec.vec_nth (vm x) k')) `
       ({vm. (\<forall>t<k. \<exists>m\<in>Hb. \<forall>x. movec.vec_nth (vm x) t = m x) \<and> (\<forall>t\<ge>k. \<forall>x. movec.vec_nth (vm x) t = 0)} \<times> Hb)"
      by auto
  qed
  then show ?case sorry
qed


lemma aux857: "(x::real) \<ge> 1 \<Longrightarrow> z \<ge> 0 \<Longrightarrow> x+z \<le> x*(1+z)"
proof -
  assume "x\<ge>1" "z\<ge>0"
  moreover from this have "x*z \<ge> z"
    by (metis mult_cancel_right2 ordered_comm_semiring_class.comm_mult_left_mono
        semiring_normalization_rules(7))
  ultimately show "x+z \<le> x*(1+z)"
    by (simp add: distrib_left)
qed


lemma two_le_e: "(2::real) < exp 1" using  exp_less_mono
  by (metis exp_ge_add_one_self less_eq_real_def ln_2_less_1 ln_exp numeral_Bit0 numeral_One) 


lemma ln_bound_linear: "x>0 \<Longrightarrow> ln (x::real) \<le> x*(exp (-1))"
proof -
  fix x::real
  assume "x>0"
  have f1: "\<forall>r. r + ln x = ln (x *\<^sub>R exp r)"
    by (simp add: \<open>0 < x\<close> ln_mult)
  have "\<forall>r ra. (ra::real) + (- ra + r) = r"
    by simp
  then have "exp (ln(x)) \<le> exp(x*(exp(-1)))"
    using f1 by (metis (no_types) \<open>0 < x\<close> exp_ge_add_one_self exp_gt_zero
                 exp_le_cancel_iff exp_ln mult_pos_pos real_scaleR_def)
  then show "ln x \<le> x * exp (- 1)"
    by blast
qed

lemma ln_bound_linear2: "x>0 \<Longrightarrow> (exp 1) * ln (x::real) \<le> x"
  by (metis (no_types, hide_lams) add.inverse_inverse divide_inverse exp_gt_zero exp_minus
      ln_bound_linear mult.commute pos_divide_le_eq)
  
lemma ln_bound_linear3: "x>0 \<Longrightarrow> a\<le>exp 1 \<Longrightarrow> a > 0 \<Longrightarrow> a * ln (x::real) \<le> x"
proof -
assume a1: "0 < x"
assume a2: "0 < a"
  assume a3: "a \<le> exp 1"
  have f4: "\<forall>r ra. (ra::real) \<le> r \<or> \<not> ra < r"
    by (simp add: linear not_less)
  then have f5: "\<forall>r. r \<le> x \<or> 0 < r"
    using a1 by (meson dual_order.trans not_less)
  have f6: "\<not> a < 0"
    using f4 a2 by (meson not_less)
  have f7: "\<forall>r ra rb. ((r::real) \<le> rb \<or> ra < r) \<or> rb < ra"
    by (meson dual_order.trans not_less)
  have f8: "\<forall>r. r < x \<or> \<not> r < exp 1 * ln x"
    using a1 by (meson dual_order.trans ln_bound_linear2 not_less)
  have f9: "\<forall>r. \<not> (r::real) < r"
by blast
have "\<not> exp 1 < a"
  using a3 not_less by blast
  then show ?thesis
    using f9 f8 f7 f6 f5 f4 by (metis (no_types) mult_less_cancel_right zero_less_mult_iff)
qed
    


lemma fixes a b::real
  assumes "b\<ge>0"
    and "a\<ge>sqrt(exp 1)"
  shows aux937: "(2*a*ln(a) + b) - a * ln (2*a*ln(a) + b) > 0"
proof -
  have "2*ln(sqrt(exp 1)) = 1"
    by (simp add: ln_sqrt)
  then have f1: "2*ln(a) \<ge> 1" using assms(2)
    by (smt ln_le_cancel_iff not_exp_le_zero real_sqrt_gt_zero) 
  have f2: "a > 1"
    using assms(2) less_le_trans less_numeral_extra(1) one_less_exp_iff real_sqrt_gt_1_iff by blast 
  have f3: "b/a \<ge> 0" using assms(1) f2 by auto


  have "2*ln(a) + b/a \<le> 2*ln(a)*(1+b/a)" using aux857 f1 f3 by auto
  then have "ln (2*ln(a) + b/a) \<le> ln (2*ln(a)*(1+b/a))"
    using f1 f3 by auto 
  then have f4: "- a * ln(2*ln(a)+b/a) \<ge> - a * ln (2*ln(a)*(1+b/a))"
    using f2 by auto
  have f5: "ln(2*ln(a)*(1+b/a)) = ln(2*ln(a)) + ln(1+b/a)"
    using f1 f3 ln_mult by auto

  have "2*a*ln(a) + b = a*(2*ln(a)+b/a)"
    using f2 by (simp add: distrib_left mult.commute)
  moreover have "(2*ln(a)+b/a) > 0"
    using f1 f3 by linarith 
  ultimately have "ln (2*a*ln(a) + b) = ln a + ln(2*ln(a)+b/a)"
    using ln_mult f2 by auto
  then have "(2*a*ln(a) + b) - a * ln (2*a*ln(a) + b)
              = 2*a*ln(a) + b - a * (ln a + ln(2*ln(a)+b/a))" by auto
  also have "... = a*ln(a) + b - a * ln(2*ln(a)+b/a)"
    by (simp add: distrib_left) 
  also have "... \<ge>
            a*ln(a) + b - a * ln(2*ln(a)*(1+b/a))" using f4 by auto

  also have "a*ln(a) + b - a * ln(2*ln(a)*(1+b/a))
           = a*ln(a) - a * ln(2*ln(a)) + b - a * ln(1+b/a)"
    using f5 by (simp add: distrib_left)
  finally have f6: "(2*a*ln(a) + b) - a * ln (2*a*ln(a) + b)
                \<ge> a*ln(a) - a * ln(2*ln(a)) + b - a * ln(1+b/a)" by auto

  have "b/a - a/a * ln(1+b/a) \<ge> 0" using f2 f3 ln_add_one_self_le_self by auto
  then have f7: "b - a * ln(1+b/a) \<ge> 0" using f2
    by (metis diff_ge_0_iff_ge dual_order.trans nonzero_mult_div_cancel_left not_le
        real_mult_le_cancel_iff2 times_divide_eq_left times_divide_eq_right zero_le_one) 


   have "a \<ge> exp 1 * ln a"
    using f2 ln_bound_linear2 by auto
   moreover have "exp 1 * ln a > 2 * ln a" using two_le_e f2
     using ln_gt_zero mult_less_cancel_right_disj by blast 
   ultimately have "ln a > ln (2 * ln a)" 
     using f1 by (metis exp_gt_zero less_le_trans less_numeral_extra(1)
         ln_less_cancel_iff not_numeral_less_zero zero_less_mult_iff)  
   then have "(ln(a)-ln(2*ln(a)))>0" by auto
   then have "a*ln(a) - a * ln(2*ln(a)) > 0"
     using f2 by auto
   from this f6 f7 show ?thesis by auto
qed


lemma fixes x a b::real
  assumes "x>0" 
      and "a>0"
      and "x \<ge> 2*a*ln(a)"
    shows aux683: "x \<ge> a* ln(x)" 
proof (cases "a<sqrt(exp 1)")
  case True
  moreover have "(1::real) < exp 1"
    by auto
  ultimately have "a \<le> exp (1::real)"
    by (metis eucl_less_le_not_le exp_gt_zero exp_half_le2 exp_ln linear ln_exp ln_sqrt not_less
        order.trans real_sqrt_gt_zero two_le_e)
  then show ?thesis using ln_bound_linear3 assms(1,2) by auto
next
  case c1: False
  obtain b where "x = (2*a*ln(a) + b)" "b\<ge>0" using assms(3)
    by (metis add.commute add.group_left_neutral add_mono_thms_linordered_field(1) diff_add_cancel
        le_less_trans less_irrefl not_le of_nat_numeral real_scaleR_def)
  moreover from this have "(2*a*ln(a) + b)  > a * ln (2*a*ln(a) + b)"
    using aux937 c1 by auto
  ultimately show ?thesis by auto
qed

lemma fixes x a::real
  shows "0 < x \<Longrightarrow> 0 < a \<Longrightarrow> x < a* ln(x) \<Longrightarrow> x < 2*a*ln(a)"
  using aux683 by (meson not_less)



lemma splitf: "exp (- f (Suc t) i * y i) = ((exp (- f t i * y i)) * exp (-(w (t))*(h (t) i)*(y i)))"
proof -
  have "f (Suc t) i * - y i = - f t i * y i + - w (t) * h (t) i * y i"    
    by (simp add: distrib_right)
  then have "- f (Suc t) i * y i = - f t i * y i + - w (t) * h (t) i * y i"
    by linarith 
  then show ?thesis using exp_add by metis
qed

lemma Dalt: "D t i = (exp (- ((f t i)) * (y i))) / (sum (\<lambda>x. exp (- ((f t x)) *  (y x))) C)"
proof (induction t arbitrary: i)
  case 0
  show ?case by (simp add: sum_distrib_left cardxgtz)
next
  case c1: (Suc t)
  then have "D (Suc t) i
= ((exp (- f t i * y i) / (\<Sum>x\<in>C. exp (- f t x * y x))) * exp (-(w t)*(h t i)*(y i))) 
/ (sum (\<lambda>x. (exp (- f t x * y x) / (\<Sum>xx\<in>C. exp (- f t xx * y xx))) * exp (-(w t)*(h t x)*(y x))) C)"
    by auto
  then have s0:"D (Suc t) i
= ((exp (- f t i * y i) / (\<Sum>x\<in>C. exp (- f t x * y x))) * exp (-(w t)*(h t i)*(y i))) 
/ ((sum (\<lambda>x. (exp (- f t x * y x)) * exp (-(w t)*(h t x)*(y x))) C)/ (\<Sum>x\<in>C. exp (- f t x * y x)))"
    by (simp add: sum_divide_distrib)
     have "(\<Sum>x\<in>C. exp (- f t x * y x)) > 0" by (simp add: nonemptyx finitex sum_pos)
     from s0 this have s1:"D (Suc t) i
= ((exp (- f t i * y i)) * exp (-(w t)*(h t i)*(y i))) 
/ ((sum (\<lambda>x. (exp (- f t x * y x)) * exp (-(w t)*(h t x)*(y x))) C))"
       by simp
     from s1 splitf show ?case by simp
qed


lemma dione: "sum (\<lambda>q. D t q) C = 1"
proof-
  have "sum (\<lambda>q. D t q) C = sum (\<lambda>q. (exp (- ((f t q)) * (y q))) / (sum (\<lambda>x. exp (- ((f t x)) *  (y x))) C)) C"
    using Dalt by auto
  also have " sum (\<lambda>q. (exp (- ((f t q)) * (y q))) / (sum (\<lambda>x. exp (- ((f t x)) *  (y x))) C)) C
           =  sum (\<lambda>q. (exp (- ((f t q)) * (y q)))) C / (sum (\<lambda>x. exp (- ((f t x)) *  (y x))) C)"
    using sum_divide_distrib by (metis (mono_tags, lifting) sum.cong)
  also have "sum (\<lambda>q. (exp (- ((f t q)) * (y q)))) C / (sum (\<lambda>x. exp (- ((f t x)) *  (y x))) C) = 1"
  using sum_pos finitex nonemptyx by (smt divide_self exp_gt_zero)
  finally show ?thesis by simp
qed

lemma dgtz: "D t x > 0"
proof (cases t)
  case 0
  then show ?thesis by (simp add: cardxgtz)
next
  case (Suc nat)
  then show ?thesis using sum_pos finitex nonemptyx Dalt exp_gt_zero
    by (smt divide_pos_neg minus_divide_right)
qed

lemma assumes "(a::real) \<le> b" and "0\<le>a" and "b \<le> 1/2"
      shows amono: "a*(1-a) \<le> b*(1-b)"
proof -
  let ?c = "b-a"
  have s1:"?c \<ge> 0" using assms by auto
  have "2*a+?c \<le> 1" using assms by auto
  then have "2*a*?c+?c*?c \<le> ?c" using assms
    by (metis distrib_left mult.commute mult_left_mono mult_numeral_1_right numeral_One s1)
  then have s2: "0 \<le> ?c - 2*a*?c-?c^2" by (simp add: power2_eq_square)
  have "a*(1-a) + ?c - ?c^2 -2*a*?c = b*(1-b)"
    by (simp add: Groups.mult_ac(2) left_diff_distrib power2_eq_square right_diff_distrib)
  from this s2 show ?thesis by auto
qed


definition dez:"Z t = 1/(card C) * (sum (\<lambda>x. exp (- (f t x) * (y x))) C)"


lemma
  assumes "\<forall>t. \<epsilon> t \<le> 1/2 - \<gamma>" and "\<forall>t. \<epsilon> t \<noteq> 0" and "\<gamma> > 0"
  shows main101: "(Z (Suc t)) / (Z t) \<le> exp(-2*\<gamma>^2)"
proof -
  have s3: "\<forall>t. \<epsilon> t > 0" using sum_pos assms(2)
      by (metis (no_types, lifting) BOOST.\<epsilon>.elims BOOST_axioms dgtz sum.empty sum.infinite)
  have s1: "{x\<in>C. h t x = y x}\<inter>{x\<in>C. h t x \<noteq> y x} = {}"
    by auto
  have s2: "{x\<in>C. h t x = y x}\<union>{x\<in>C. h t x \<noteq> y x} = C"
    by auto
  have s10:"(Z (Suc t)) / (Z t) = (sum (\<lambda>x. exp (- (f (Suc t) x) * (y x))) C) / (sum (\<lambda>x. exp (- (f t x) * (y x))) C)"
    by (auto simp: dez cardxgtz)
  also have "(sum (\<lambda>x. exp (- (f (Suc t) x) * (y x))) C)
   = (sum (\<lambda>x. exp (- f t x * y x) * exp (-(w ( t))*(h ( t) x)*(y x))) C)"
    using splitf by auto
  also have "(sum (\<lambda>x. exp (- f t x * y x) * exp (-(w t)*(h t x)*(y x))) C) / (sum (\<lambda>x. exp (- (f t x) * (y x))) C)
  = (sum (\<lambda>x. exp (- f t x * y x)/ (sum (\<lambda>x. exp (- (f t x) * (y x))) C) * exp (-(w t)*(h t x)*(y x))) C)"
    using sum_divide_distrib by simp
  also have "(sum (\<lambda>x. exp (- f t x * y x)/ (sum (\<lambda>x. exp (- (f t x) * (y x))) C) * exp (-(w t)*(h t x)*(y x))) C)
      = (sum (\<lambda>x. D t x * exp (-(w t)*(h t x)*(y x))) C)"
    using Dalt by simp
  also have "sum (\<lambda>x. D t x * exp (-(w t)*(h t x)*(y x))) C
  = sum (\<lambda>x. D t x * exp (-(w t)*(h t x)*(y x))) {x\<in>C. h t x = y x}
  + sum (\<lambda>x. D t x * exp (-(w t)*(h t x)*(y x))) {x\<in>C. h t x \<noteq> y x}"
    using Groups_Big.comm_monoid_add_class.sum.union_disjoint finitex s1 s2 
    by (metis (no_types, lifting) finite_Un)
  also have "sum (\<lambda>x. D t x * exp (-(w t)*(h t x)*(y x))) {x\<in>C. h t x = y x}
            = sum (\<lambda>x. D t x * exp (-(w t))) {x\<in>C. h t x = y x}"
    by (smt add.inverse_inverse empty_iff h.elims insert_iff mem_Collect_eq mult.left_neutral mult_cancel_left2 mult_minus1_right mult_minus_right sum.cong ytwoclass)
  also have "sum (\<lambda>x. D t x * exp (-(w t)*(h t x)*(y x))) {x\<in>C. h t x \<noteq> y x}
            = sum (\<lambda>x. D t x * exp (w t)) {x\<in>C. h t x \<noteq> y x}"
    using ctov2 by (simp add: Groups.mult_ac(1))
  also have "(\<Sum>x | x \<in> C \<and> h t x = y x. D t x * exp (- w t)) +
  (\<Sum>x | x \<in> C \<and> h t x \<noteq> y x. D t x * exp (w t))
        = (\<Sum>x | x \<in> C \<and> h t x = y x. D t x) * exp (- w t) +
  (\<Sum>x | x \<in> C \<and> h t x \<noteq> y x. D t x) * exp (w t)"
    by (simp add: sum_distrib_right)
  also have "(\<Sum>x | x \<in> C \<and> h t x \<noteq> y x. D t x) = \<epsilon> t" by auto
  also have "(\<Sum>x | x \<in> C \<and> h t x = y x. D t x) = 1 - \<epsilon> t"
  proof -
    have "(\<Sum>x | x \<in> C \<and> h t x = y x. D t x) + (\<Sum>x | x \<in> C \<and> h t x \<noteq> y x. D t x)
        = sum (D t) C"
    using Groups_Big.comm_monoid_add_class.sum.union_disjoint finitex s1 s2 
      by (metis (no_types, lifting) finite_Un)
    then show ?thesis using dione
      by (smt Collect_cong \<epsilon>.simps)
  qed
  also have "exp (- w t) = 1/ exp(w t)"
    by (smt exp_minus_inverse exp_not_eq_zero nonzero_mult_div_cancel_right)
  also have "exp(w t) = sqrt (1/(\<epsilon> t)-1)"
  proof - 
    from s3 have  "(1/(\<epsilon> t)-1) > 0"
      by (smt assms(1) assms(3) less_divide_eq_1_pos)
    then have "exp (((ln (1/(\<epsilon> t)-1)) * 1/2)) = sqrt (1/(\<epsilon> t)-1)"
      by (smt exp_ln ln_sqrt real_sqrt_gt_zero)
    then show ?thesis by auto
  qed
  also have "sqrt(1/(\<epsilon> t)-1) = sqrt(1/(\<epsilon> t)-(\<epsilon> t)/(\<epsilon> t))"
    using assms(2) by (metis divide_self) 
  also have "sqrt(1/(\<epsilon> t)-(\<epsilon> t)/(\<epsilon> t)) = sqrt((1 - \<epsilon> t)/\<epsilon> t)"
    by (simp add: diff_divide_distrib)
  also have "1/(sqrt((1 - \<epsilon> t)/\<epsilon> t)) = sqrt(\<epsilon> t) / sqrt((1 - \<epsilon> t))"
    by (simp add: real_sqrt_divide)
  also have "\<epsilon> t * sqrt((1 - \<epsilon> t)/(\<epsilon> t)) =  sqrt(1 - \<epsilon> t) * sqrt(\<epsilon> t)"
    by (smt linordered_field_class.sign_simps(24) real_div_sqrt real_sqrt_divide s3 times_divide_eq_right)
  also have s19:"(1 - \<epsilon> t)* (sqrt (\<epsilon> t)/ sqrt(1 - \<epsilon> t)) = sqrt (\<epsilon> t)* sqrt(1 - \<epsilon> t)"
    using assms(1,3) by (smt less_divide_eq_1_pos mult.commute real_div_sqrt times_divide_eq_left)
  also have "sqrt (\<epsilon> t) * sqrt (1 - \<epsilon> t) + sqrt (1 - \<epsilon> t) * sqrt (\<epsilon> t)
            = 2 * sqrt((1 - \<epsilon> t) * \<epsilon> t)"
    using divide_cancel_right real_sqrt_mult by auto
  also have s20:"2* sqrt((1 - \<epsilon> t) * \<epsilon> t) \<le> 2* sqrt((1/2-\<gamma>)*(1-(1/2-\<gamma>)))"
    proof -
      have "((1 - \<epsilon> t) * \<epsilon> t) \<le> ((1/2-\<gamma>)*(1-(1/2-\<gamma>)))"
        using assms(1,3) amono s3 by (smt mult.commute)
      then show ?thesis by auto
    qed
  also have "2 * sqrt ((1 / 2 - \<gamma>) * (1 - (1 / 2 - \<gamma>))) = 2 * sqrt(1/4-\<gamma>^2)"
       by (simp add: algebra_simps power2_eq_square)
      
  also have "2 * sqrt(1/4-\<gamma>^2) = sqrt(4*(1/4-\<gamma>^2))"
    using real_sqrt_four real_sqrt_mult by presburger 
  also have "sqrt(4*(1/4-\<gamma>^2)) = sqrt(1-4*\<gamma>^2)" by auto
  also have "sqrt(1-4*\<gamma>^2) \<le> sqrt(exp(-4*\<gamma>^2))"
  proof -
    have "1-4*\<gamma>^2 \<le> exp(-4*\<gamma>^2)"
      by (metis (no_types) add_uminus_conv_diff exp_ge_add_one_self mult_minus_left)
    then show ?thesis by auto
  qed
  also have "sqrt(exp(-4*\<gamma>^2)) = exp(-4*\<gamma>^2/2)"
    by (metis exp_gt_zero exp_ln ln_exp ln_sqrt real_sqrt_gt_0_iff)
  finally show ?thesis by auto
qed

  
lemma help1:"(b::real) > 0 \<Longrightarrow> a / b \<le> c \<Longrightarrow> a \<le> b * c"
  by (smt mult.commute pos_less_divide_eq)

definition defloss: "loss t = 1/(card C) *(sum (\<lambda>x. (if (f t x * (y x)) > 0 then 0 else 1)) C)"


lemma
  assumes "\<forall>t. \<epsilon> t \<le> 1/2 - \<gamma>" and "\<forall>t. \<epsilon> t \<noteq> 0" and "\<gamma> > 0"
  shows main102: "loss T \<le> exp (-2*\<gamma>^2*T)"
proof -
  have s1: "\<forall>k. Z k > 0"
    using dez finitex nonemptyx cardxgtz by (simp add: sum_pos)
  have s2: "Z T \<le> exp(-2*\<gamma>^2*T)"
  proof (induction T)
    case 0
    then show ?case 
      by (simp add: dez)
    next
      case c1:(Suc T)
    from main101 s1 have s3:"Z (Suc T) \<le> exp (-2*\<gamma>^2) * Z T"
      by (metis assms(1) assms(2) assms(3) help1 mult.commute)
    from c1 have "exp (-2*\<gamma>^2) * Z T  \<le> exp (-2*\<gamma>^2 *T) * exp (-2*\<gamma>^2)" by auto
    from this s3 show ?case
      by (smt exp_of_nat_mult power_Suc2 semiring_normalization_rules(7)) 
     (* by (smt Groups.mult_ac(2) exp_of_nat2_mult power.simps(2)) This proof worked on other version*)
  qed
  have help3: "\<forall>n. sum (\<lambda>x. if 0 < f T x * y x then 0 else 1) C \<le> sum (\<lambda>x. exp (- (f T x * y x))) C"
    by (simp add: sum_mono)
  then have s3: "loss T \<le> Z T" 
    by (simp add: defloss dez divide_right_mono)
  from s2 s3 show ?thesis by auto
qed
end

locale allboost =
  fixes X :: "'a set"
    and y :: "'a \<Rightarrow> real"
    and oh :: "('a \<Rightarrow> real) \<Rightarrow> 'a \<Rightarrow> real"
    and T :: nat
    and B :: "('a \<Rightarrow> real) set"
assumes infx: "infinite X"
    and ytwoclass: "\<forall>x. y x \<in> {-1,1}"
    and ohtwoclass: "\<forall>Ds. oh Ds \<in> B"
    and defonB: "\<forall>h x. h \<in> B \<longrightarrow> h x \<in> {- 1, 1}"
    and nonemptyB: "B \<noteq> {}"
    and Tgtz: "0 < T"
begin
term BOOST.hyp


definition "H t = (\<lambda>S. BOOST.hyp S y oh t) `{S. S\<subseteq>X \<and> S\<noteq>{} \<and> finite S}"
definition "H' t = (\<lambda>(S, oh). BOOST.hyp S y oh t) `({S. S\<subseteq>X \<and> S\<noteq>{}}\<times>{oh. \<forall>DS. oh DS \<in> B})"


interpretation outer: vcd X "{True, False}" "H T"
proof
  show "card {True, False} = 2" by auto
  show "\<forall>h x. h \<in> H T \<longrightarrow> h x \<in> {True, False}" by auto
  have "{S. S \<subseteq> X \<and> S \<noteq> {}} \<noteq> {}"
    using allboost_axioms allboost_def order_refl by fastforce 
  then show "H T \<noteq> {}" unfolding H_def by blast
  show "infinite X"
    using allboost_axioms allboost_def by blast
qed

interpretation baseclass: vcd X "{-1::real,1}" B
proof
  show "card {- 1::real, 1} = 2" by auto
  show "\<forall>h x. h \<in> B \<longrightarrow> h x \<in> {- 1, 1}"
    by (meson allboost_axioms allboost_def)
  show  "B \<noteq> {}" "infinite X" using allboost_axioms allboost_def by auto
qed

lemma baux: "(\<lambda>h. h |` C) ` baseclass.H_map = (\<lambda>h. restrict_map (mapify h) C) ` B" by auto

lemma "baseclass.VCDim = Some d \<Longrightarrow> 0 < d \<Longrightarrow> d \<le> card C \<Longrightarrow> C \<subseteq> X \<Longrightarrow> card ((\<lambda>h. restrict_map (mapify h) C) ` B) \<le> (d+1)*(card C)^d"
  using baseclass.resforboost[of C d] baux by auto


lemma aux1: "BOOST S y oh \<Longrightarrow> BOOST.hyp S y oh k = (\<lambda>i. (linear_predictor (vec_lambda (\<lambda>t. (if t<k then BOOST.w S y oh t else 0))) 
             (vec_lambda (\<lambda>t. (if t<k then (oh (BOOST.D S y oh t) i) else 0)))))"
proof -
  assume a1: "BOOST S y oh"
  then have "BOOST.hyp S y oh k = (\<lambda>i. 0 < BOOST.f S y oh k i)" using BOOST.hyp_def by fastforce
  also have "(\<lambda>i. 0 < BOOST.f S y oh k i) = (\<lambda>i. (linear_predictor (vec_lambda (\<lambda>t. (if t<k then BOOST.w S y oh t else 0))) 
             (vec_lambda (\<lambda>t. (if t<k then BOOST.h S y oh t i else 0)))))" using BOOST.convert_f a1 by auto
  finally have s1: "BOOST.hyp S y oh k = (\<lambda>i. (linear_predictor (vec_lambda (\<lambda>t. (if t<k then BOOST.w S y oh t else 0))) 
             (vec_lambda (\<lambda>t. (if t<k then BOOST.h S y oh t i else 0)))))" by auto
  moreover have s1: "\<And>t i. BOOST.h S y oh t i = oh (BOOST.D S y oh t) i"
    by (simp add: BOOST.h.simps a1)
  then have "\<And> i. (\<lambda>t. (if t<k then BOOST.h S y oh t i else 0)) = (\<lambda>t. (if t<k then oh (BOOST.D S y oh t) i else 0))"
    by auto 
  then have "(\<lambda>i. (linear_predictor (vec_lambda (\<lambda>t. (if t<k then BOOST.w S y oh t else 0))) 
             (vec_lambda (\<lambda>t. (if t<k then BOOST.h S y oh t i else 0)))))
       = (\<lambda>i. (linear_predictor (vec_lambda (\<lambda>t. (if t<k then BOOST.w S y oh t else 0))) 
             (vec_lambda (\<lambda>t. (if t<k then (oh (BOOST.D S y oh t) i) else 0)))))" by auto
  then show "BOOST.hyp S y oh k = (\<lambda>i. (linear_predictor (vec_lambda (\<lambda>t. (if t<k then BOOST.w S y oh t else 0))) 
             (vec_lambda (\<lambda>t. (if t<k then (oh (BOOST.D S y oh t) i) else 0)))))" using s1
    by (simp add: calculation)
qed
   


lemma aux02: "\<forall>S\<in>{S. S\<subseteq>X \<and> S\<noteq>{} \<and> finite S}. BOOST S y oh \<Longrightarrow> H k = (\<lambda>S i. (linear_predictor (vec_lambda (\<lambda>t. (if t<k then BOOST.w S y oh t else 0))) 
             (vec_lambda (\<lambda>t. (if t<k then (oh (BOOST.D S y oh t) i) else 0)))))`{S. S\<subseteq>X \<and> S\<noteq>{} \<and> finite S}"
   using aux1[of _ k] H_def[of k]
   by (smt image_cong) 

lemma aux01: "(\<lambda>S i. (linear_predictor (vec_lambda (\<lambda>t. (if t<k then BOOST.w S y oh t else 0))) 
             (vec_lambda (\<lambda>t. (if t<k then (oh (BOOST.D S y oh t) i) else 0)))))`{S. S\<subseteq>X \<and> S\<noteq>{} \<and> finite S}
\<subseteq> (\<lambda>(S,S') i. (linear_predictor (vec_lambda (\<lambda>t. (if t<k then BOOST.w S y oh t else 0))) 
             (vec_lambda (\<lambda>t. (if t<k then (oh (BOOST.D S' y oh t) i) else 0)))))`({S. S\<subseteq>X \<and> S\<noteq>{} \<and> finite S}\<times>{S. S\<subseteq>X \<and> S\<noteq>{} \<and> finite S})"
  by auto

lemma aux2: "(\<lambda> i. (linear_predictor (vec_lambda (\<lambda>t. (if t<k then BOOST.w S y oh t else 0))) 
       (vec_lambda (\<lambda>t. (if t<k then (oh (BOOST.D S' y oh t) i) else 0)))))
=((\<lambda>v. linear_predictor (vec_lambda (\<lambda>t. (if t<k then BOOST.w S y oh t else 0)))  v)
 \<circ> (\<lambda>i. (vec_lambda (\<lambda>t. (if t<k then (oh (BOOST.D S' y oh t) i) else 0)))))"
  by auto

lemma aux3: "(\<lambda>(S, S')i. (linear_predictor (vec_lambda (\<lambda>t. (if t<k then BOOST.w S y oh t else 0))) 
       (vec_lambda (\<lambda>t. (if t<k then (oh (BOOST.D S' y oh t) i) else 0))))) ` ({S. S\<subseteq>X \<and> S\<noteq>{} \<and> finite S}\<times>{S. S\<subseteq>X \<and> S\<noteq>{} \<and> finite S}) 
=(\<lambda>(S,S').(\<lambda>v. linear_predictor (vec_lambda (\<lambda>t. (if t<k then BOOST.w S y oh t else 0)))  v)
 \<circ> (\<lambda>i. (vec_lambda (\<lambda>t. (if t<k then (oh (BOOST.D S' y oh t) i) else 0))))) ` ({S. S\<subseteq>X \<and> S\<noteq>{} \<and> finite S}\<times>{S. S\<subseteq>X \<and> S\<noteq>{} \<and> finite S})"
  using aux2 by simp

definition "WH k = (\<lambda>S. linear_predictor (vec_lambda (\<lambda>t. (if t<k then BOOST.w S y oh t else 0)))) ` {S. S\<subseteq>X \<and> S\<noteq>{} \<and> finite S}"

definition "Agg k = (\<lambda>S' i. (vec_lambda (\<lambda>t. (if t<k then (oh (BOOST.D S' y oh t) i) else 0)))) ` {S. S\<subseteq>X \<and> S\<noteq>{} \<and> finite S}"

    
lemma WH_subset: "WH k \<subseteq> all_linear(myroom k)"
proof -
  have "\<forall>S. (movec.vec_lambda (\<lambda>t. if t < k then BOOST.w S y oh t else 0)) \<in> {x. \<forall>q\<ge>k. movec.vec_nth x q = 0}"
  proof auto
    fix S q
    show "k \<le> q \<Longrightarrow> movec.vec_nth (movec.vec_lambda (\<lambda>t. if t < k then BOOST.w S y oh t else 0)) q = 0"
      using vec_lambda_inverse lt_valid[of k "BOOST.w S y oh"] by auto
  qed
  then show ?thesis unfolding WH_def all_linear_def myroom_def
    by auto
qed

interpretation vectors: linpred T
proof
  show "0<T" using Tgtz by auto
qed

lemma vecmain: "T \<le> card C \<Longrightarrow> C \<subseteq> (myroom T) \<Longrightarrow> card ((\<lambda>h. restrict_map (mapify h) C) ` (all_linear (myroom T))) \<le> (T+1)*(card C)^T"
  using vectors.vmain by auto

lemma aux259: "A\<subseteq>D \<Longrightarrow> ((\<lambda>h. mapify h |` C) ` A) \<subseteq> ((\<lambda>h. mapify h |` C) ` D)" by auto

lemma vec1: "finite C \<Longrightarrow> T \<le> card C \<Longrightarrow> C \<subseteq> (myroom T) \<Longrightarrow> card ((\<lambda>h. restrict_map (mapify h) C) ` (WH T)) \<le> (T+1)*(card C)^T"
  using vecmain WH_subset[of T] vectors.vfinite card_mono aux259[of "WH T" "all_linear (myroom T)"]
proof -
  assume a1: "C \<subseteq> myroom T"
  assume a2: "T \<le> card C"
  assume "finite C"
  then have "card ((\<lambda>p. mapify p |` C) ` WH T) \<le> card ((\<lambda>p. mapify p |` C) ` all_linear (myroom T))"
    by (simp add: \<open>WH T \<subseteq> all_linear (myroom T)\<close> \<open>\<And>B A. \<lbrakk>finite B; A \<subseteq> B\<rbrakk> \<Longrightarrow> card A \<le> card B\<close> \<open>\<And>C. WH T \<subseteq> all_linear (myroom T) \<Longrightarrow> (\<lambda>h. mapify h |` C) ` WH T \<subseteq> (\<lambda>h. mapify h |` C) ` all_linear (myroom T)\<close> vectors.vfinite)
  then show ?thesis
    using a2 a1 le_trans vecmain by blast
qed


(*
lemma "Agg k \<subseteq> {vm. (\<forall>t<k. \<exists>m\<in>B. \<forall>x. vec_nth (vm (x::'a)) t = m x) \<and> (\<forall>t\<ge>k. \<forall>x. vec_nth (vm x) t = 0) }"
  unfolding Agg_def
proof auto
  fix xa t S'
  assume a1:"S' \<subseteq> X" "finite S'" "xa \<in> S'" "t < k"
  have "\<forall>x. (\<lambda>t. (if t < k then oh (BOOST.D S' y oh t) x else 0)) \<in> {f. \<exists>k. \<forall>q>k. f q = 0}"
    by (metis (no_types) lt_valid)
  then have "\<forall>x. movec.vec_nth (movec.vec_lambda (\<lambda>t. if t < k then oh (BOOST.D S' y oh t) x else 0)) t = (if t < k then oh (BOOST.D S' y oh t) x else 0)" using movec.vec_lambda_inverse by auto
  moreover have "\<exists>m\<in>B. \<forall>x. (if t < k then oh (BOOST.D S' y oh t) x else 0) = m x" using a1(4) ohtwoclass by auto
  ultimately show " \<exists>m\<in>B. \<forall>x. movec.vec_nth (movec.vec_lambda (\<lambda>t. if t < k then oh (BOOST.D S' y oh t) x else 0)) t = m x" by auto
  
qed
*)
lemma aux4: "(\<lambda>(S,S').(\<lambda>v. linear_predictor (vec_lambda (\<lambda>t. (if t<k then BOOST.w S y oh t else 0)))  v)
 \<circ> (\<lambda>i. (vec_lambda (\<lambda>t. (if t<k then (oh (BOOST.D S' y oh t) i) else 0))))) ` ({S. S\<subseteq>X \<and> S\<noteq>{} \<and> finite S}\<times>{S. S\<subseteq>X \<and> S\<noteq>{} \<and> finite S})
= {boost. \<exists>w\<in>(WH k). \<exists>a\<in>(Agg k). boost = w \<circ> a}" unfolding WH_def Agg_def by auto

lemma aux5: "\<forall>S\<in>{S. S\<subseteq>X \<and> S\<noteq>{} \<and> finite S}. BOOST S y oh" unfolding BOOST_def
  using allboost_axioms ohtwoclass ytwoclass defonB by auto

lemma "H k \<subseteq> {boost. \<exists>w\<in>(WH k). \<exists>a\<in>(Agg k). boost = w \<circ> a}"
  using aux4 aux3 aux01 aux02 aux5 by auto


lemma "(\<lambda>h. restrict_map (mapify h) C) ` {boost. \<exists>w\<in>(WH k). \<exists>a\<in>(Agg k). boost = w \<circ> a}  \<subseteq>
      {map. \<exists>a\<in>((\<lambda>h. restrict_map (mapify h) C) ` (Agg k)). \<exists>w\<in>((\<lambda>h. restrict_map (mapify h) (ran a)) ` (WH k)).
       map = w \<circ>\<^sub>m a}"
proof safe
  fix w a
  assume "w \<in> WH k" "a \<in> Agg k"
  moreover have "mapify (w\<circ>a) = (mapify w) \<circ>\<^sub>m (mapify a)" unfolding mapify_alt map_comp_def by auto
  moreover have "((mapify w) \<circ>\<^sub>m (mapify a)) |` C = (mapify w) \<circ>\<^sub>m ((mapify a) |` C)"
    unfolding restrict_map_def map_comp_def by auto
  moreover have "(mapify w) \<circ>\<^sub>m ((mapify a) |` C) = ((mapify w)|` ran ((mapify a) |` C)) \<circ>\<^sub>m ((mapify a) |` C)"
    unfolding restrict_map_def map_comp_def ran_def
  proof -
    { fix aa :: 'a
      have ff1: "\<forall>aa. (\<exists>ab. (ab \<in> C \<longrightarrow> mapify a ab = Some (a aa)) \<and> (ab \<notin> C \<longrightarrow> None = Some (a aa))) \<or> aa \<notin> C"
        by (metis mapify_def)
      have "a aa \<in> {m. \<exists>aa. (aa \<in> C \<longrightarrow> mapify a aa = Some m) \<and> (aa \<notin> C \<longrightarrow> None = Some m)} \<longrightarrow> (if a aa \<in> {m. \<exists>aa. (aa \<in> C \<longrightarrow> mapify a aa = Some m) \<and> (aa \<notin> C \<longrightarrow> None = Some m)} then mapify w (a aa) else None) = Some (w (a aa))"
        by (simp add: mapify_def)
      moreover
      { assume "(if a aa \<in> {m. \<exists>aa. (aa \<in> C \<longrightarrow> mapify a aa = Some m) \<and> (aa \<notin> C \<longrightarrow> None = Some m)} then mapify w (a aa) else None) = Some (w (a aa))"
        then have "aa \<in> C \<longrightarrow> (case if aa \<in> C then Some (a aa) else None of None \<Rightarrow> None | Some x \<Rightarrow> (Some \<circ> w) x) = (case if aa \<in> C then Some (a aa) else None of None \<Rightarrow> None | Some m \<Rightarrow> if m \<in> {m. \<exists>aa. (aa \<in> C \<longrightarrow> mapify a aa = Some m) \<and> (aa \<notin> C \<longrightarrow> None = Some m)} then mapify w m else None)"
          by simp }
      ultimately have "aa \<in> C \<longrightarrow> (case if aa \<in> C then Some (a aa) else None of None \<Rightarrow> None | Some x \<Rightarrow> (Some \<circ> w) x) = (case if aa \<in> C then Some (a aa) else None of None \<Rightarrow> None | Some m \<Rightarrow> if m \<in> {m. \<exists>aa. (aa \<in> C \<longrightarrow> mapify a aa = Some m) \<and> (aa \<notin> C \<longrightarrow> None = Some m)} then mapify w m else None)"
        using ff1 by blast
      then have "(case if aa \<in> C then Some (a aa) else None of None \<Rightarrow> None | Some x \<Rightarrow> (Some \<circ> w) x) = (case if aa \<in> C then Some (a aa) else None of None \<Rightarrow> None | Some m \<Rightarrow> if m \<in> {m. \<exists>aa. (aa \<in> C \<longrightarrow> mapify a aa = Some m) \<and> (aa \<notin> C \<longrightarrow> None = Some m)} then mapify w m else None)"
        by force
      then have "(case if aa \<in> C then mapify a aa else None of None \<Rightarrow> None | Some x \<Rightarrow> mapify w x) = (case if aa \<in> C then mapify a aa else None of None \<Rightarrow> None | Some m \<Rightarrow> if m \<in> {m. \<exists>aa. (aa \<in> C \<longrightarrow> mapify a aa = Some m) \<and> (aa \<notin> C \<longrightarrow> None = Some m)} then mapify w m else None)"
        by (metis (no_types) mapify_alt mapify_def) }
    then show "(\<lambda>aa. case if aa \<in> C then mapify a aa else None of None \<Rightarrow> None | Some x \<Rightarrow> mapify w x) = (\<lambda>aa. case if aa \<in> C then mapify a aa else None of None \<Rightarrow> None | Some m \<Rightarrow> if m \<in> {m. \<exists>aa. (if aa \<in> C then mapify a aa else None) = Some m} then mapify w m else None)"
      by presburger
  qed
  ultimately show "\<exists>aa\<in>(\<lambda>h. mapify h |` C) ` Agg k. \<exists>wa\<in>(\<lambda>h. mapify h |` ran aa) ` WH k. mapify (w \<circ> a) |` C = wa \<circ>\<^sub>m aa"
    by auto
qed

lemma aux843: "finite (dom f) \<Longrightarrow> card (ran f) \<le> card (dom f)"
proof -
  assume "finite (dom f)"
  moreover have "Some ` (ran f) = f ` (dom f)"
    by (smt Collect_cong Collect_mono aux41 domI image_def mem_Collect_eq ran_def)
  moreover have "card (ran f) = card (Some ` (ran f))"
    by (simp add: card_image) 
  ultimately show "card (ran f) \<le> card (dom f)"
    by (simp add: card_image_le)
qed


definition "Agg_res k C = ((\<lambda>h. restrict_map (mapify h) C) ` (Agg k))"
definition "WH_res k C agg = ((\<lambda>h. restrict_map (mapify h) (ran agg)) ` (WH k))"

lemma aux630: "movec.vec_lambda (\<lambda>t. if t < k then oh (BOOST.D S y oh t) i else 0) \<in> myroom k" 
    using lt_valid[of k "(\<lambda>t. oh (BOOST.D S y oh t) i)"] myroom_def[of k] vec_lambda_inverse by auto

lemma "finite C \<Longrightarrow> T \<le> card C \<Longrightarrow> C \<subseteq> (myroom T) \<Longrightarrow> card ((\<lambda>h. restrict_map (mapify h) C) ` (WH T)) \<le> (T+1)*(card C)^T"
  oops



lemma assumes "finite C" "a\<in>Agg_res k C"
  shows vec2: "card (ran a) \<le> card C" "ran a \<subseteq> myroom k"
proof -
  have "dom a \<subseteq> C" using assms(2) Agg_res_def
    by (simp add: dom_mapify_restrict)
  then show "card (ran a) \<le> card C" using card_mono assms(1) aux843
    by (metis infinite_super le_trans)
   obtain S where o1: "S\<in>{S. S \<subseteq> X \<and> S \<noteq> {} \<and> finite S}"
      "a = (\<lambda>h. mapify h |` C) (\<lambda>i. movec.vec_lambda (\<lambda>t. if t < k then oh (BOOST.D S y oh t) i else 0))"
     using Agg_res_def Agg_def assms(2) by auto
  show "ran a \<subseteq> myroom k" 
  proof
    fix r
    assume a1: "r\<in> ran a"
    then obtain x where o2: "a x = Some r"
    proof -
      assume a1: "\<And>x. a x = Some r \<Longrightarrow> thesis"
      have "r \<in> {m. \<exists>aa. a aa = Some m}"
        by (metis \<open>r \<in> ran a\<close> ran_def)
      then show ?thesis
        using a1 by blast
    qed
    moreover have "a x = Some (movec.vec_lambda (\<lambda>t. if t < k then oh (BOOST.D S y oh t) x else 0))"
    proof -
      have "x \<in> C"
        using o2 \<open>dom a \<subseteq> C\<close> by blast
      then show ?thesis
        by (simp add: mapify_def o1(2))
    qed
    ultimately have "r = movec.vec_lambda (\<lambda>t. if t < k then oh (BOOST.D S y oh t) x else 0)" by auto
    then show "r\<in> myroom k" using myroom_def aux630[of k] by auto
  qed
qed


lemma
  assumes "finite C" "a\<in>Agg_res T C" "T \<le> card C" "T \<le> card (ran a)"
  shows "card (WH_res T C a) \<le> (T+1)*(card C)^T"
  using vec1[of "ran a"] vec2[of C a T] WH_res_def[of T C a] assms
proof -
  have "dom a = C" using assms(2) Agg_res_def mapify_def 
  proof -
    obtain mm :: "('a \<Rightarrow> movec) set \<Rightarrow> (('a \<Rightarrow> movec) \<Rightarrow> 'a \<Rightarrow> movec option) \<Rightarrow> ('a \<Rightarrow> movec option) \<Rightarrow> 'a \<Rightarrow> movec" where
      f1: "\<forall>x0 x1 x2. (\<exists>v3. x2 = x1 v3 \<and> v3 \<in> x0) = (x2 = x1 (mm x0 x1 x2) \<and> mm x0 x1 x2 \<in> x0)"
      by moura
    have "a \<in> (\<lambda>f. mapify f |` C) ` Agg T"
      using Agg_res_def assms(2) by blast
    then have f2: "a = mapify (mm (Agg T) (\<lambda>f. mapify f |` C) a) |` C"
      using f1 by (meson imageE)
    have "C = dom (mapify (mm (Agg T) (\<lambda>f. mapify f |` C) a)) \<inter> C"
      by (simp add: mapify_def)
    then show ?thesis
      using f2 by (metis dom_restrict)
  qed
  then have "finite (ran a)" using assms(1)
    by (simp add: finite_ran)
  then have "card (WH_res T C a) \<le> (T+1)*(card (ran a))^T"
    using vec1[of "ran a"] vec2[of C a T] WH_res_def[of T C a] assms by auto
  moreover have "card (ran a) \<le> card C"
    using vec2[of C a T] assms by auto
  ultimately show ?thesis using power_mono[of "card (ran a)" "card C" T] Tgtz
    by (meson le0 le_trans nat_mult_le_cancel_disj)
qed


(*
definition "Agg_res_trans k C = {vm. (\<forall>t<k. \<exists>m\<in>((\<lambda>h. restrict_map (mapify h) C) ` B). \<forall>x. (case vm x of Some z \<Rightarrow> Some (vec_nth z t) = m x | None \<Rightarrow> x\<notin>C))
            \<and> (\<forall>t\<ge>k. \<forall>x. (case vm x of Some z \<Rightarrow> z = 0 | None \<Rightarrow> x\<notin>C))}"

lemma "Agg_res k C \<subseteq> Agg_res_trans k C" unfolding Agg_res_def Agg_def Agg_res_trans_def
proof auto
 fix t S' xb
  assume "t < k"
  let ?m = "oh (BOOST.D S' y oh t)"
  have "case (mapify (\<lambda>i. movec.vec_lambda (\<lambda>t. if t < k then oh (BOOST.D S' y oh t) i else 0)) |`
                        C)
                        xb of
                  None \<Rightarrow> xb \<notin> C | Some z \<Rightarrow> Some (movec.vec_nth z t) = (mapify ?m |` C) xb" 
    apply (cases "xb\<in>C") apply auto
  then have "\<forall>x. (mapify (\<lambda>i. movec.vec_lambda (\<lambda>t. if t < k then oh (BOOST.D S' y oh t) i else 0)) |`C) x
            = (mapify (\<lambda>i. movec.vec_lambda (\<lambda>t. if t < k then oh (BOOST.D S' y oh t) i else 0)) |`C) x"
    by auto
  obtain z where o1: "mapify (\<lambda>i. movec.vec_lambda (\<lambda>t. if t < k then oh (BOOST.D S' y oh t) i else 0)) xb = Some z"
    by (simp add: mapify_def)
  then have "z = (\<lambda>i. movec.vec_lambda (\<lambda>t. if t < k then oh (BOOST.D S' y oh t) i else 0)) xb" by (simp add: mapify_def)
  then have s1: "\<forall>t. vec_nth z t = (if t < k then oh (BOOST.D S' y oh t) xb else 0)"
    using vec_lambda_inverse lt_valid[of k "(\<lambda>t. oh (BOOST.D S' y oh t) xb)"] by auto
  then have "(\<forall>t<k. \<exists>m\<in>B. Some (movec.vec_nth z t) = mapify m xb)"
    using ohtwoclass mapify_def by metis 
  moreover have "\<forall>t\<ge>k. movec.vec_nth z t = 0" using s1 by auto
  ultimately have "\<exists>z. mapify (\<lambda>i. movec.vec_lambda (\<lambda>t. if t < k then oh (BOOST.D S' y oh t) i else 0)) xb = Some z \<and>
           (\<forall>t<k. \<exists>m\<in>B. Some (movec.vec_nth z t) = mapify m xb) \<and> (\<forall>t\<ge>k. movec.vec_nth z t = 0)"
    using o1 by auto

(*{vm. (\<forall>t<k. \<exists>m\<in>((\<lambda>h. restrict_map (mapify h) C) ` B). \<forall>x. Some (vec_nth (vm (x::'a)) t) = m x) \<and> (\<forall>t\<ge>k. \<forall>x. vec_nth (vm x) t = 0) }*)
lemma "Agg_res k C \<subseteq> {vm. (\<forall>x\<in>C. \<exists>z. vm x = Some z \<and> (\<forall>t<k. \<exists>m\<in>((\<lambda>h. restrict_map (mapify h) C) ` B).
     Some (vec_nth z t) = m x) \<and> (\<forall>t\<ge>k. (vec_nth z t) = 0)) \<and> (\<forall>x. x\<notin>C \<longrightarrow> vm x = None)}"
  unfolding Agg_res_def Agg_def
proof auto
  fix xb S'
  assume "xb\<in>C"
  obtain z where o1: "mapify (\<lambda>i. movec.vec_lambda (\<lambda>t. if t < k then oh (BOOST.D S' y oh t) i else 0)) xb = Some z"
    by (simp add: mapify_def)
  then have "z = (\<lambda>i. movec.vec_lambda (\<lambda>t. if t < k then oh (BOOST.D S' y oh t) i else 0)) xb" by (simp add: mapify_def)
  then have s1: "\<forall>t. vec_nth z t = (if t < k then oh (BOOST.D S' y oh t) xb else 0)"
    using vec_lambda_inverse lt_valid[of k "(\<lambda>t. oh (BOOST.D S' y oh t) xb)"] by auto
  then have "(\<forall>t<k. \<exists>m\<in>B. Some (movec.vec_nth z t) = mapify m xb)"
    using ohtwoclass mapify_def by metis 
  moreover have "\<forall>t\<ge>k. movec.vec_nth z t = 0" using s1 by auto
  ultimately show "\<exists>z. mapify (\<lambda>i. movec.vec_lambda (\<lambda>t. if t < k then oh (BOOST.D S' y oh t) i else 0)) xb = Some z \<and>
           (\<forall>t<k. \<exists>m\<in>B. Some (movec.vec_nth z t) = mapify m xb) \<and> (\<forall>t\<ge>k. movec.vec_nth z t = 0)"
    using o1 by auto
qed
*)
lemma aux296: "(a::nat) \<le> b * c \<Longrightarrow> b \<le> c ^ (d::nat) \<Longrightarrow> c \<ge> 0  \<Longrightarrow> a \<le> c ^ (Suc d)"
  by (metis dual_order.trans mult.commute mult_right_mono power_Suc)

lemma mapify_restrict_alt: "mapify h |` C = (\<lambda>x. if x\<in>C then Some (h x) else None)"
  by (metis mapify_def restrict_in restrict_out)

lemma assumes "finite C"
  shows "card (Agg_res k C) \<le> card ((\<lambda>h. restrict_map (mapify h) C) ` B) ^ k"
proof(induct k)
  case 0
  let ?f = "(\<lambda>x. if x\<in>C then Some 0 else None)"
  let ?A = "((\<lambda>h. mapify h |` C) `
      (\<lambda>S' i. movec.vec_lambda (\<lambda>t. if t < 0 then oh (BOOST.D S' y oh t) i else 0)) `
      {S. S \<subseteq> X \<and> S \<noteq> {} \<and> finite S})"
  have s0: "{S. S \<subseteq> X \<and> S \<noteq> {} \<and> finite S} \<noteq> {}" using infx sorry
  then have "(\<lambda>S' i. movec.vec_lambda (\<lambda>t. if t < 0 then oh (BOOST.D S' y oh t) i else 0)) `
      {S. S \<subseteq> X \<and> S \<noteq> {} \<and> finite S} = {(\<lambda>i. 0)}" using zero_movec_def by auto
  then have "card ?A \<le> 1" using card_image_le by auto
  then show ?case unfolding Agg_res_def Agg_def by auto 
next
  case c1: (Suc k)
  let ?SucA = "Agg_res (Suc k) C"
  let ?A = "Agg_res k C"
  let ?resB = "(\<lambda>h. mapify h |` C) ` B"
  let ?conv = "(\<lambda>(vm, g). (\<lambda>x. (case (vm x) of Some z \<Rightarrow> Some (vec_lambda 
  (\<lambda>t. if t=k then (case g x of Some x' \<Rightarrow> x') else vec_nth z t)) | None \<Rightarrow> None)))"
  have s1: "?SucA \<subseteq>
     ?conv ` (?A \<times> ?resB)"
  proof
    fix vm
    assume a1: "vm\<in>?SucA"
    then obtain S where o1: "S\<in>{S. S \<subseteq> X \<and> S \<noteq> {} \<and> finite S}"
      "vm = (\<lambda>h. mapify h |` C) ((\<lambda>S' i. movec.vec_lambda (\<lambda>t. if t < Suc k then oh (BOOST.D S' y oh t) i else 0)) S)"
      unfolding Agg_res_def Agg_def by auto
    have s2: "dom vm = C" using a1 Agg_res_def
      by (simp add: dom_mapify_restrict)
    let ?vm = "(\<lambda>x. (case (vm x) of Some z \<Rightarrow> Some (vec_lambda 
  (\<lambda>t. if t=k then 0 else vec_nth z t)) | None \<Rightarrow> None))"
    let ?vm' = "(\<lambda>h. mapify h |` C) ((\<lambda>S' i. movec.vec_lambda (\<lambda>t. if t < k then oh (BOOST.D S' y oh t) i else 0)) S)"
    have "\<forall>x. ?vm x = ?vm' x"
    proof
      fix x
      show "(case vm x of None \<Rightarrow> None
          | Some z \<Rightarrow> Some (movec.vec_lambda (\<lambda>t. if t = k then 0 else movec.vec_nth z t))) =
         (mapify (\<lambda>i. movec.vec_lambda (\<lambda>t. if t < k then oh (BOOST.D S y oh t) i else 0)) |` C) x"
      proof(cases "vm x")
        case None
        moreover from this have "x\<notin>C" using s2 by auto
        ultimately show ?thesis by auto
      next
        case c1: (Some a)
        then have s3: "x\<in>C" using s2 by auto
        then have s4: "(mapify (\<lambda>i. movec.vec_lambda (\<lambda>t. if t < k then oh (BOOST.D S y oh t) i else 0)) |` C) x
        =  Some ( movec.vec_lambda (\<lambda>t. if t < k then oh (BOOST.D S y oh t) x else 0))"
          by (meson mapify_restrict_alt)
        have "a = movec.vec_lambda (\<lambda>t. if t < Suc k then oh (BOOST.D S y oh t) x else 0)"
          using o1(2) c1 s3 
            mapify_restrict_alt[of "(\<lambda>i. movec.vec_lambda (\<lambda>t. if t < Suc k then oh (BOOST.D S y oh t) i else 0))" C]
          by auto
        then have "\<forall>t. (\<lambda>t. if t = k then 0 else movec.vec_nth a t) t = (\<lambda>t. if t < k then oh (BOOST.D S y oh t) x else 0) t"
          using vec_lambda_inverse lt_valid[of "Suc k" "(\<lambda>t. oh (BOOST.D S y oh t) x)"] by auto
        then have "(\<lambda>t. if t = k then 0 else movec.vec_nth a t) = (\<lambda>t. if t < k then oh (BOOST.D S y oh t) x else 0)"
          by auto
        then show ?thesis
          by (simp add: c1 s4) 
      qed
    qed
    then have s100: "?vm \<in> ?A" unfolding Agg_res_def Agg_def using o1(1) by auto
    have "oh (BOOST.D S y oh k) \<in> B" using ohtwoclass by auto
    then have "mapify (oh (BOOST.D S y oh k)) |` C \<in> ?resB" by auto
    then have s101: "(\<lambda>x. if x\<in>C then Some (oh (BOOST.D S y oh k) x) else None) \<in> ?resB" 
      using mapify_restrict_alt[of "oh (BOOST.D S y oh k)" C] by auto
    have s102: "vm = ?conv (?vm,(\<lambda>x. if x\<in>C then Some (oh (BOOST.D S y oh k) x) else None))"
    proof
      fix x
      show "vm x =
         (case (\<lambda>x. case vm x of None \<Rightarrow> None
                     | Some z \<Rightarrow> Some (movec.vec_lambda (\<lambda>t. if t = k then 0 else movec.vec_nth z t)),
                \<lambda>x. if x \<in> C then Some (oh (BOOST.D S y oh k) x) else None) of
          (vm, g) \<Rightarrow>
            \<lambda>x. case vm x of None \<Rightarrow> None
                 | Some z \<Rightarrow>
                     Some
                      (movec.vec_lambda
                        (\<lambda>t. if t = k then case g x of Some x' \<Rightarrow> x' else movec.vec_nth z t)))
          x"
      proof(cases "vm x")
        case None
        then show ?thesis by auto
      next
        case c1: (Some a)
        moreover from this have s3: "x\<in>C" using s2 by auto
        ultimately show ?thesis apply auto
        proof -
          have s4: "a = movec.vec_lambda (\<lambda>t. if t < Suc k then oh (BOOST.D S y oh t) x else 0)"
            using o1(2) c1 s3 
              mapify_restrict_alt[of "(\<lambda>i. movec.vec_lambda (\<lambda>t. if t < Suc k then oh (BOOST.D S y oh t) i else 0))" C]
            by auto
          then have "\<forall>t. (\<lambda>t. if t = k then 0 else movec.vec_nth a t) t = (\<lambda>t. if t < k then oh (BOOST.D S y oh t) x else 0) t"
            using vec_lambda_inverse lt_valid[of "Suc k" "(\<lambda>t. oh (BOOST.D S y oh t) x)"] by auto
          then have "(\<lambda>t. if t = k then 0 else movec.vec_nth a t) = (\<lambda>t. if t < k then oh (BOOST.D S y oh t) x else 0)"
            by auto
          then have s5: "movec.vec_lambda (\<lambda>t. if t = k then (oh (BOOST.D S y oh k) x)  else
     movec.vec_nth (movec.vec_lambda (\<lambda>t. if t = k then 0 else movec.vec_nth a t)) t)
      = movec.vec_lambda (\<lambda>t. if t = k then (oh (BOOST.D S y oh k) x)  else
     movec.vec_nth (movec.vec_lambda (\<lambda>t. if t < k then oh (BOOST.D S y oh t) x else 0)) t)" 
            by metis
          have "movec.vec_nth (movec.vec_lambda (\<lambda>t. if t < k then oh (BOOST.D S y oh t) x else 0))
              = (\<lambda>t. if t < k then oh (BOOST.D S y oh t) x else 0)" 
            using vec_lambda_inverse lt_valid[of k "(\<lambda>t. oh (BOOST.D S y oh t) x)"] by auto

          then have "movec.vec_lambda (\<lambda>t. if t = k then (oh (BOOST.D S y oh k) x)  else
     (movec.vec_nth (movec.vec_lambda (\<lambda>t. if t < k then oh (BOOST.D S y oh t) x else 0))) t)
       = movec.vec_lambda (\<lambda>t. if t = k then (oh (BOOST.D S y oh k) x)  else
     (\<lambda>t. if t < k then oh (BOOST.D S y oh t) x else 0) t)" by presburger
          moreover have "...
        = movec.vec_lambda (\<lambda>t. if t < Suc k then oh (BOOST.D S y oh t) x else 0)"
            by (metis (full_types) less_Suc_eq) 
          ultimately have "a = movec.vec_lambda (\<lambda>t. if t = k then (oh (BOOST.D S y oh k) x)  else
     movec.vec_nth (movec.vec_lambda (\<lambda>t. if t = k then 0 else movec.vec_nth a t)) t)"
            using s4 s5 by auto
          then show "a =
    movec.vec_lambda
     (\<lambda>t. if t = k then case Some (oh (BOOST.D S y oh k) x) of Some x' \<Rightarrow> x'
           else movec.vec_nth (movec.vec_lambda (\<lambda>t. if t = k then 0 else movec.vec_nth a t)) t)"
            by (metis option.simps(5)) 
        qed
      qed
    qed
    from s100 s101 have "(?vm,(\<lambda>x. if x\<in>C then Some (oh (BOOST.D S y oh k) x) else None)) \<in> (?A \<times> ?resB)"
      by auto
    from this s102 show "vm \<in> ?conv ` (?A \<times> ?resB)" by blast
  qed
  then have "finite ?A \<Longrightarrow> finite ?resB \<Longrightarrow> card ?SucA \<le> card ?A * card ?resB"
  proof -
    assume a1: "finite ?A" "finite ?resB"
    then have "finite (?conv ` (?A \<times> ?resB))" by auto
    then have "card ?SucA \<le> card (?A \<times> ?resB)" 
      using s1 card_image_le[of "(?A \<times> ?resB)" ?conv] a1 card_mono[of "(?conv ` (?A \<times> ?resB))" ?SucA] by auto
    then show "card ?SucA \<le> card ?A * card ?resB"
      using card_cartesian_product[of ?A ?resB] by auto
  qed
  moreover have "finite ?resB" using assms sorry
  moreover have "finite ?A" sorry
  ultimately have "card ?SucA \<le> card ?A * card ?resB" by auto
  then show ?case using aux296 c1 by auto
qed

(*
lemma assumes "finite C"
  shows "card ({vm. (\<forall>x\<in>C. \<exists>z. vm x = Some z \<and> (\<forall>t<k. \<exists>m\<in>((\<lambda>h. restrict_map (mapify h) C) ` B).
     Some (vec_nth z t) = m x) \<and> (\<forall>t\<ge>k. (vec_nth z t) = 0)) \<and> (\<forall>x. x\<notin>C \<longrightarrow> vm x = None)}) \<le> card ((\<lambda>h. restrict_map (mapify h) C) ` B) ^ k"
proof(induct k)
  case 0
  let ?f = "(\<lambda>x. if x\<in>C then Some 0 else None)"
  let ?A = "{vm. (\<forall>x\<in>C. \<exists>z. vm x = Some z \<and>
                  (\<forall>t<0. \<exists>m\<in>(\<lambda>h. mapify h |` C) ` B. Some (movec.vec_nth z t) = m x) \<and>
                  (\<forall>t\<ge>0. movec.vec_nth z t = 0)) \<and> (\<forall>x. x \<notin> C \<longrightarrow> vm x = None)}"
  have s1: "?f\<in>?A"
    by simp
  have "\<forall>g\<in>?A.  \<forall>x. g x = (if x\<in>C then Some 0 else None)"
    using movec_eq_iff by auto
  then have "\<forall>g\<in>?A.  g = ?f"
    by auto
  then have "card ?A = 1"
    using s1 only_one[of ?f ?A] by simp
  then show ?case by auto 
next
  case c1: (Suc k)
  let ?SucA = "{vm.(\<forall>x\<in>C. \<exists>z. vm x = Some z \<and>
                   (\<forall>t<Suc k. \<exists>m\<in>(\<lambda>h. mapify h |` C) ` B. Some (movec.vec_nth z t) = m x) \<and>
                   (\<forall>t\<ge>Suc k. movec.vec_nth z t = 0)) \<and> (\<forall>x. x \<notin> C \<longrightarrow> vm x = None)}"
  let ?A = "   {vm.(\<forall>x\<in>C. \<exists>z. vm x = Some z \<and>
                   (\<forall>t<k. \<exists>m\<in>(\<lambda>h. mapify h |` C) ` B. Some (movec.vec_nth z t) = m x) \<and>
                   (\<forall>t\<ge>k. movec.vec_nth z t = 0)) \<and> (\<forall>x. x \<notin> C \<longrightarrow> vm x = None)}"
  let ?resB = "(\<lambda>h. mapify h |` C) ` B"
  let ?conv = "(\<lambda>(vm, g). (\<lambda>x. (case (vm x) of Some z \<Rightarrow> Some (vec_lambda 
  (\<lambda>t. if t=k then (case g x of Some x' \<Rightarrow> x') else vec_nth z t)) | None \<Rightarrow> None)))"
  have s1: "?SucA \<subseteq>
     ?conv ` (?A \<times> ?resB)"
  proof auto
    fix vm
    assume "\<forall>xa\<in>C.
            \<exists>z. vm xa = Some z \<and>
                (\<forall>t<Suc k. \<exists>m\<in>B. Some (movec.vec_nth z t) = mapify m xa) \<and>
                (\<forall>t\<ge>Suc k. movec.vec_nth z t = 0)"
            " \<forall>xa. xa \<notin> C \<longrightarrow> vm xa = None"
    let ?vm = "(\<lambda>x. (case (vm x) of Some z \<Rightarrow> Some (vec_lambda 
  (\<lambda>t. if t=k then 0 else vec_nth z t)) | None \<Rightarrow> None))"
  (*proof (auto)
    fix vm
    assume a1: "\<forall>t<Suc k. \<exists>m\<in>Hb. \<forall>xa. movec.vec_nth (vm xa) t = m xa"
            "\<forall>t\<ge>Suc k. \<forall>xa. movec.vec_nth (vm xa) t = 0"
    let ?kM = "{vm. (\<forall>t<k. \<exists>m\<in>Hb. \<forall>x. movec.vec_nth (vm x) t = m x) \<and> (\<forall>t\<ge>k. \<forall>x. movec.vec_nth (vm x) t = 0)}"
    let ?wm = "(\<lambda>x. upd_movec (vm x) k 0)"
    have "?wm\<in>?kM" sorry
    obtain h where o1: "h\<in>Hb" "\<forall>x. vec_nth (vm x) k = h x" using a1 by auto

    have "\<exists>wm\<in>{vm. (\<forall>t<k. \<exists>m\<in>Hb. \<forall>x. movec.vec_nth (vm x) t = m x) \<and> (\<forall>t\<ge>k. \<forall>x. movec.vec_nth (vm x) t = 0)}. \<exists>h\<in>Hb.
   vm = (\<lambda>(vm, g) x. movec.vec_lambda (\<lambda>k'. if k' = k then g x else movec.vec_nth (vm x) k')) (wm, h)"
      sorry
    then show "vm \<in> (\<lambda>(vm, g) x. movec.vec_lambda (\<lambda>k'. if k' = k then g x else movec.vec_nth (vm x) k')) `
       ({vm. (\<forall>t<k. \<exists>m\<in>Hb. \<forall>x. movec.vec_nth (vm x) t = m x) \<and> (\<forall>t\<ge>k. \<forall>x. movec.vec_nth (vm x) t = 0)} \<times> Hb)"
      by auto
  qed *)
  then have "finite ?A \<Longrightarrow> finite ?resB \<Longrightarrow> card ?SucA \<le> card ?A * card ?resB"
  proof -
    assume a1: "finite ?A" "finite ?resB"
    then have "finite (?conv ` (?A \<times> ?resB))" by auto
    then have "card ?SucA \<le> card (?A \<times> ?resB)" 
      using s1 card_image_le[of "(?A \<times> ?resB)" ?conv] a1 card_mono[of "(?conv ` (?A \<times> ?resB))" ?SucA] by auto
    then show "card ?SucA \<le> card ?A * card ?resB"
      using card_cartesian_product[of ?A ?resB] by auto
  qed
  moreover have "finite ?resB" using assms sorry
  moreover have "finite ?A" sorry
  ultimately have "card ?SucA \<le> card ?A * card ?resB" by auto
  then show ?case using aux296 c1 by auto
qed
  
  using ohtwoclass defonB 
  oops

*)
lemma "\<Union>((\<lambda>a. ((\<lambda>w. (w, a)) ` (WH_res k C a))) ` Agg_res k C)
= {dum. \<exists>a\<in>(Agg_res k C). \<exists>w\<in>(WH_res k C a). dum = (w, a)}" 

lemma "\<forall>a\<in>Agg_res k C. card (WH_res k C a) \<le> c1 \<and> finite (WH_res k C a)
\<Longrightarrow> card (Agg_res k C) \<le> c2 \<and> finite (Agg_res k C)
 \<Longrightarrow> card (\<Union>((\<lambda>a. ((\<lambda>w. (w, a)) ` (WH_res k C a))) ` Agg_res k C))
 \<le> c1 * c2" 

lemma "\<forall>a\<in>Agg_res k C. card (WH_res k C a) \<le> c1 \<and> finite (WH_res k C a)
\<Longrightarrow> card (Agg_res k C) \<le> c2 \<and> finite (Agg_res k C)
 \<Longrightarrow> card {map. \<exists>a\<in>(Agg_res k C). \<exists>w\<in>(WH_res k C a). map = w \<circ>\<^sub>m a}
 \<le> c1 * c2" 

lemma "{map. \<exists>a\<in>((\<lambda>h. restrict_map (mapify h) C) ` (Agg k)). \<exists>w\<in>((\<lambda>h. restrict_map (mapify h) (ran a)) ` (WH k)).
       map = w \<circ>\<^sub>m a} = (\<lambda>a. ((\<lambda>h. restrict_map (mapify h) (ran a)) ` (WH k))) ` ((\<lambda>h. restrict_map (mapify h) C) ` (Agg k))"

lemma "(\<lambda>(S,S') i. (linear_predictor (vec_lambda (\<lambda>t. (if t<k then BOOST.w S y oh t else 0))) 
       (vec_lambda (\<lambda>t. (if t<k then (oh (BOOST.D S' y oh t) i) else 0)))))`({S. S\<subseteq>X \<and> S\<noteq>{} \<and> finite S}\<times>{S. S\<subseteq>X \<and> S\<noteq>{} \<and> finite S})
\<subseteq>(\<lambda>(w, S'). (\<lambda>v. linear_predictor w v) \<circ> (\<lambda>i. (vec_lambda (\<lambda>t. (if t<k then (oh (BOOST.D S' y oh t) i) else 0)))))
   ` (((\<lambda>S. (vec_lambda (\<lambda>t. (if t<k then BOOST.w S y oh t else 0)))) ` {S. S\<subseteq>X \<and> S\<noteq>{} \<and> finite S})\<times>{S. S\<subseteq>X \<and> S\<noteq>{} \<and> finite S})"


lemma "(\<lambda>S i. (linear_predictor (vec_lambda (\<lambda>t. (if t<k then BOOST.w S y oh t else 0))) 
             (vec_lambda (\<lambda>t. (if t<k then (oh (BOOST.D S y oh t) i) else 0)))))`{S. S\<subseteq>X \<and> S\<noteq>{} \<and> finite S}
\<subseteq> (\<lambda>(S,b) i. (linear_predictor (vec_lambda (\<lambda>t. (if t<k then BOOST.w S y oh t else 0))) 
             (vec_lambda (\<lambda>t. (if t<k then (b i) else 0)))))`({S. S\<subseteq>X \<and> S\<noteq>{} \<and> finite S}\<times>B)"
proof
  fix x
  assume "x \<in> (\<lambda>S i. linear_predictor (movec.vec_lambda (\<lambda>t. if t < k then BOOST.w S y oh t else 0))
                     (movec.vec_lambda (\<lambda>t. if t < k then oh (BOOST.D S y oh t) i else 0))) `
             {S. S \<subseteq> X \<and> S \<noteq> {} \<and> finite S}"
  then obtain S where "S\<in>{S. S \<subseteq> X \<and> S \<noteq> {} \<and> finite S}" "x = (\<lambda>S i. linear_predictor (movec.vec_lambda (\<lambda>t. if t < k then BOOST.w S y oh t else 0))
                     (movec.vec_lambda (\<lambda>t. if t < k then oh (BOOST.D S y oh t) i else 0))) S" by auto
  obtain b where "b\<in>B" "\<forall>t. b = oh (BOOST.D S y oh t)" using ohtwoclass nonemptyB 


lemma "{vm. (\<forall>t<k. \<exists>m\<in>Hb. \<forall>x. vec_nth (vm (x::'a)) t = m x) \<and> (\<forall>t\<ge>k. \<forall>x. vec_nth (vm x) t = 0) }"



find_theorems name:allboost

term outer.H_map

lemma "\<forall>C\<subseteq>X. restrictH outer.H_map C {True, False} \<subseteq> "