import data.list algebra.ring tactic.omega defs single height

lemma branch_son : ∀ t s : tree, ⟨ t ⟩ → is_son s t → ⟨ s ⟩ := 
begin
  intros t,
  induction t,
  begin intros s H1 H2, cases H2 end, -- single case 
  repeat { -- left and right cases
    begin intros s H1 H2, cases H1, cases H2, assumption end,
  },
  begin 
    intros s H1 H2,
    cases H1, cases H2, assumption, apply is_branch.single, 
    cases H2, apply is_branch.single, assumption 
  end
end

lemma branch_with_two_sons : ∀ b b' : tree, 
      ⟨⟦b, b'⟧⟩ → b = ● ∨ b' = ● := 
begin
  intros b b' H1, 
  cases H1, 
  begin right, refl end, 
  begin left, refl end
end

def gen_link : ℕ → tree
| 0 := ● 
| (nat.succ n) := ⟦●, gen_link n⟧

lemma gen_link_branch : ∀ n, ⟨gen_link n⟩ :=
begin
  intros n, induction n, 
  unfold gen_link, apply is_branch.single, 
  unfold gen_link, apply is_branch.right_l, assumption
end

lemma gen_link_height : ∀ n, height (gen_link n) = n + 1 := 
begin
  intros n, 
  induction n, 
  simp, unfold gen_link height, 
  unfold gen_link height, 
  have ht : _ := height_ge1 (gen_link n_n),
  have ht' : _ := ge.le ht,  
  have ht2 : _ := max_eq_right ht', rewrite ht2, omega 
end

lemma height_max_1_left : ∀ t, max (height t) 1 = height t := 
begin
  intros t, have ht : 1 ≤ height t := ge.le (height_ge1 _),
  apply max_eq_left, assumption
end

lemma height_max_1_right : ∀ t, max 1 (height t) = height t := 
begin
  intros t, have ht : 1 ≤ height t := ge.le (height_ge1 _),
  apply max_eq_right, assumption
end

lemma grow_high_tree : ∀ t, ⟨t⟩ → ∀ h, (∃ t', ⟨t'⟩ ∧ (t ↣ t') ∧ height t' = height t + h) := 
begin
  intros t a, 
  induction a, 
  begin intros, existsi (gen_link h), split, exact gen_link_branch _, split, apply grow.single_grow, rewrite (gen_link_height _), unfold height, omega end,
  begin
    intros h, cases a_ih h, existsi ⟦w∣⟧, split,
    apply is_branch.left_nl, tauto, split,
    apply grow.left_grow, tauto, 
    unfold height, rewrite h_1.right.right, omega 
  end,
  begin 
    intros h, cases a_ih h, existsi ⟦w, ●⟧, split,
    apply is_branch.left_l, tauto, split,
    apply grow.full_grow, tauto, apply grow.single_grow,
    unfold height, repeat {rewrite height_max_1_left},
    rewrite h_1.right.right, omega
  end,
  begin 
    intros h, cases a_ih h, existsi ⟦∣w⟧, split,
    apply is_branch.right_nl, tauto, split,
    apply grow.right_grow, tauto, 
    unfold height, rewrite h_1.right.right, omega,
  end,
  begin 
    intros h, cases a_ih h, existsi ⟦●, w⟧, split,
    apply is_branch.right_l, tauto, split,
    apply grow.full_grow, apply grow.single_grow, tauto,  
    unfold height, repeat {rewrite height_max_1_right},
    rewrite h_1.right.right, omega
  end
end

lemma branch_grow : ∀ b b' : tree, ⟨ b ⟩ → (b' ↣ b) → ⟨ b' ⟩ := 
begin
  intro b,
  induction b,
  begin -- single node 
    intros b H1 H2,
    cases H2, assumption
  end,
  begin -- left branch
    intros b H1 H2,
    cases H2, apply is_branch.single,  
    have H3 : is_son b_a ⟦b_a∣⟧, 
    apply is_son.left_left,
    have H4 : is_son H2_t ⟦H2_t∣⟧,
    apply is_son.left_left,
    have H5 : ⟨b_a⟩, eapply branch_son, exact H1, assumption, 
    have H6 : ⟨H2_t⟩, eapply b_ih, repeat { assumption },  
    apply is_branch.left_nl, assumption,
  end, 
  begin
    intros b H1 H2,
    cases H2, apply is_branch.single,
    have H3 : is_son b_a ⟦∣ b_a⟧, 
    apply is_son.right_right,
    have H4 : is_son H2_t ⟦∣ H2_t⟧, 
    apply is_son.right_right,
    have H5 : ⟨b_a⟩, eapply branch_son, exact H1, assumption,
    have H6 : ⟨H2_t⟩, eapply b_ih, repeat { assumption },
    apply is_branch.right_nl, assumption
  end,
  begin
    intros b H1 H2,
    cases H2, apply is_branch.single,   
    have H3  : is_son b_a ⟦b_a, b_a_1⟧, apply is_son.left_full,
    have H3' : is_son b_a_1 ⟦b_a, b_a_1⟧, apply is_son.right_full,
    have H4  : is_son H2_t1 ⟦H2_t1, H2_t1⟧, apply is_son.left_full,
    have H4' : is_son H2_t2 ⟦H2_t1, H2_t2⟧, apply is_son.right_full,
    have H5  : ⟨b_a⟩, eapply branch_son, exact H1, assumption, 
    have H5' : ⟨b_a_1⟩, eapply branch_son, exact H1, assumption, 
    have H6  : ⟨H2_t1⟩, eapply b_ih_a, repeat { assumption },
    have H6' : ⟨H2_t2⟩, eapply b_ih_a_1, repeat { assumption }, 
    have H7  : b_a = ● ∨ b_a_1 = ●, 
      apply branch_with_two_sons, assumption,
    cases H7, 
    begin 
      rewrite H7 at H2_a,
      have H8 : H2_t1 = ●, apply single_grow, assumption, 
      rewrite H8, 
      apply is_branch.right_l, assumption
    end, 
    begin 
      rewrite H7 at H2_a_1, 
      have H8 : H2_t2 = ●, apply single_grow, assumption, 
      rewrite H8, 
      apply is_branch.left_l, assumption, 
    end
  end
end 

lemma branch_prefix : ∀ b t t' : tree, ⟨b⟩ → (t ↣ b) → (t' ↣ b) 
                                 → (height t ≤ height t') → (t ↣ t') := 
begin
  intros b, 
  induction b,
  begin -- base case, which is trivial since b = ●
    intros, 
    have h1 : t = ●, apply single_grow, assumption,
    rewrite h1, apply grow.single_grow
  end,
  begin -- left
    intros t t' h1 h2 h3 h4, 
    cases t, 
    begin apply grow.single_grow end,
    begin 
      cases h3, 
      begin 
        unfold height at h4, 
        have ht : height t ≥ 1, apply height_ge1, exfalso, 
        have ht' : height t = 0, omega, 
        rewrite ht' at ht, cases ht
      end,
      begin
        cases h2, 
        unfold height at h4, 
        cases h1,  
        have ht : height t ≤ height h3_t, omega, 
        have ht' : (t ↣ h3_t), apply b_ih, repeat {assumption}, 
        apply grow.left_grow, 
        assumption 
      end
    end, 
    cases h3, cases h2, cases h2,
    cases h3, cases h2, cases h2, 
  end,
  begin -- right 
    intros t t' h1 h2 h3 h4, 
    cases t, 
    begin apply grow.single_grow end, 
    cases h3, cases h2, cases h2,
    begin 
      cases h3, 
      begin
        unfold height at h4, 
        have ht : height t ≥ 1, apply height_ge1, exfalso, 
        have ht' : height t = 0, omega, 
        rewrite ht' at ht, cases ht, 
      end,
      begin
        cases h2, 
        unfold height at h4, 
        cases h1, 
        have ht : height t ≤ height h3_t, omega, 
        have ht' : (t ↣ h3_t), apply b_ih, repeat {assumption}, 
        apply grow.right_grow, 
        assumption
      end
    end,
    cases h3, cases h2, cases h2
  end,
  begin -- full
    intros t t' h1 h2 h3 h4, 
    cases t, 
    begin apply grow.single_grow end,
    cases h3, cases h2, cases h2, cases h2,
    cases t', 
    begin 
      unfold height at h4,
      have ht : height t_a ≤ max (height t_a) (height t_a_1), apply le_max_left,
      have ht' : height t_a = 0, omega, 
      have ht'' : height t_a ≥ 1, apply height_ge1, 
      rewrite ht' at ht'', cases ht''
    end, 
    begin cases h3 end,
    begin cases h3 end,
    begin 
      cases h2, cases h3, unfold height at h4, 
      have h4' : max (height t_a) (height t_a_1) ≤ max (height t'_a) (height t'_a_1), omega, 
      have ht : max (height t'_a) (height t'_a_1) = height t'_a ∨ max (height t'_a) (height t'_a_1) = height t'_a_1, apply max_choice,
      have ht' : max (height t_a) (height t_a_1) ≤ height t'_a ∨ max (height t_a) (height t_a_1) ≤ height t'_a_1,
      begin 
        cases ht, 
        begin rewrite ht at h4, left, omega end,
        begin rewrite ht at h4, right, omega end,
      end,
      cases ht',
      begin
        have hl : height t_a ≤ height t'_a, exact le_of_max_le_left ht',
        have hr : height t_a_1 ≤ height t'_a, exact le_of_max_le_right ht',
        cases h1,
        begin 
          have ht1 : t_a_1 = ●, apply single_grow, assumption,
          have ht2 : t'_a_1 = ●, apply single_grow, assumption,
          rewrite ht1 at *, rewrite ht2 at *, 
          have res_l : (t_a ↣ t'_a), 
          begin apply b_ih_a, repeat {assumption} end,
          apply grow.full_grow, repeat {assumption},
        end,
        begin
          have ht1 : t_a = ●, apply single_grow, assumption, 
          have ht2 : t'_a = ●, apply single_grow, assumption,
          rewrite ht1 at *, rewrite ht2 at *,
          unfold height at *, 
          have ht3 : t_a_1 = ●, apply height_le1_single, assumption, 
          rewrite ht3 at *, 
          apply grow.full_grow, repeat {apply grow.single_grow},   
        end
      end,
      begin
        have hl : height t_a ≤ height t'_a_1, exact le_of_max_le_left ht', 
        have hr : height t_a_1 ≤ height t'_a_1, exact le_of_max_le_right ht', 
        cases h1, 
        begin
          have ht1 : t_a_1 = ●, apply single_grow, assumption,
          have ht2 : t'_a_1 = ●, apply single_grow, assumption,
          rewrite ht1 at *, rewrite ht2 at *,
          unfold height at *, 
          have ht3 : t_a = ●, apply height_le1_single, assumption,
          rewrite ht3 at *,
          apply grow.full_grow, repeat {apply grow.single_grow},
        end,
        begin
          have ht1 : t_a = ●, apply single_grow, assumption, 
          have ht2 : t'_a = ●, apply single_grow, assumption, 
          rewrite ht1 at *, rewrite ht2 at *,
          have res_r : (t_a_1 ↣ t'_a_1), 
          begin apply b_ih_a_1, repeat {assumption} end,
          apply grow.full_grow, repeat {assumption}
        end
      end
    end
  end
end
  