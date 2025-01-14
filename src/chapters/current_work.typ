#let behavioral = "behavioral retention"
#let resource = "resource efficiency"

= Current Work

== Algebraic Q-value Scalarization (AQS)
A fundamental limitation in reinforcement learning is the reliance on linear reward composition, which often proves brittle and unintuitive when designing desired policy behaviors. While practitioners can theoretically achieve any behavior through careful reward engineering, this process is often time-consuming, requires significant domain expertise, and can lead to suboptimal results. This challenge is particularly acute in real-world applications with multiple competing objectives.

To address these limitations, we developed Algebraic Q-value Scalarization (AQS), a novel domain-specific language that allows practitioners to express how different objectives should interact. Rather than focusing on reward engineering, AQS enables direct specification of when one objective should take priority over another based on their current satisfaction levels. Key innovations include:
1. Using the power-mean as a logical operator over normalized Q-values
2. Q-value scalarization instead of traditional reward scalarization
3. Q-value normalization for stable learning across objectives
4. Integration with a new DDPG-based algorithm called Balanced Policy Gradient (BPG)

This approach fundamentally changes how we express objectives in reinforcement learning. Rather than trying to encode complex behaviors through reward engineering, AQS provides an intuitive language for specifying how objectives should be prioritized. For example, if one objective is nearly satisfied while another is not, AQS can naturally express that the unsatisfied objective should take priority - similar to how an AND operator works in Boolean logic, but generalized to continuous values.

The results demonstrated comprehensive improvements across multiple dimensions. We achieved up to 600% improvement in sample efficiency compared to Soft Actor Critic, along with substantial reductions in policy variability. By providing a more principled way to express objective relationships, AQS enables practitioners to focus on what behaviors they want rather than how to engineer rewards to achieve those behaviors.

This approach improves both #behavioral (see @def-behavioral), by making objective relationships explicit and verifiable, and #resource (see @def-resource), by enabling more sample-efficient learning through better objective specification.

While previous work like Anchor Critics showed the power of Q-values for preserving behaviors across domains, AQS demonstrates their potential for expressing complex objective relationships. By normalizing Q-values to [0,1], we can treat them as continuous measures of objective satisfaction:

==== Q-value Normalization $Q_"norm"(s,a) = (Q(s,a) - Q_"min")/(Q_"max" - Q_"min")$ <q-norm>
The normalized Q-value $Q_"norm"$ is bounded to [0,1], representing the relative satisfaction of an objective.

This normalization enables the use of power-mean operators (see @power-mean) to express logical relationships between objectives.

== Anchor Critics for Robust Transfer
A key challenge in robot learning is maintaining policy behavior when transitioning from simulation to reality. While real-world data is essential for adaptation, critical scenarios often occur rarely in practice. This leads to a fundamental problem: policies optimized on real-world data can maintain good average performance while catastrophically forgetting how to handle important edge cases that were learned in simulation.

This challenge directly relates to #behavioral (see @def-behavioral) - the ability of a policy to maintain its learned behaviors when transferred to new domains. Traditional approaches focus on average-case performance, but fail to preserve behavior in critical scenarios that occur rarely in real data but are crucial for safe operation.

We formalize this challenge through Q-value optimization:

==== Retention Score
#align(center)[
  $R_"retention" = min_(s in S_"critical") { Q_"sim"(s,pi(s)) }$ <retention>
]
where $R_"retention"$ quantifies how well the policy preserves behaviors learned in simulation across critical scenarios $S_"critical"$.

==== Combined Objective
#align(center)[
  $Q_"combined" = M_p(Q_"real", R_"retention")$ <combined>
]
where $Q_"combined"$ represents the overall objective that balances real-world adaptation with behavioral retention.

Building on our experience with CAPS, we also incorporate smoothness objectives multiplicatively:

==== Smoothness Loss
#align(center)[
  $J_pi = M_0(Q_pi, w_T/(w_T + L_T), w_S/(w_S + L_S), w_A/(w_A + pi^":-1"))$ <smooth-anchor>
]
where $L_T$ and $L_S$ are temporal and spatial smoothness terms from @temporal and @spatial, $Q_pi$ is the critic's Q-value, $pi^":-1"$ is the pre-activation policy output, and $w_T$, $w_S$, $w_A$ are penalty thresholds. The geometric mean ($M_0$) ensures all objectives must be satisfied simultaneously while maintaining the [0,1] bounds established in @q-norm.

This composition proved more effective for preserving smoothness during transfer, achieving:

- 47% reduction in control jerk compared to additive composition
- 52% lower power consumption on real hardware
- Maintained tracking performance within 5% of simulation baseline

The final objective combines smoothness with our retention score using AQS's power-mean operator:

==== Final Objective
#align(center)[
  $Q_"final" = M_p(Q_"combined", L_"smooth")$ <final-obj>
]
where $Q_"combined"$ is from @combined and $M_p$ is the power-mean operator from @power-mean. This unifies our three key insights:
- Smoothness through direct policy regularization (CAPS)
- Behavioral retention through Q-value anchoring
- Objective composition through power-mean operators (AQS)

The multiplicative composition creates a natural AND relationship between objectives - both temporal and spatial smoothness must be satisfied simultaneously, aligning with the intuition developed in our AQS work (@power-mean).

Our Anchor Critics method addresses this by treating sim-to-real transfer as multi-objective optimization over Q-values from both domains. By using Q-values from simulation as "anchors", we can preserve important behaviors learned in simulation while still allowing the policy to adapt to reality. This is particularly powerful because simulation allows us to deliberately train on critical scenarios, making those Q-values effective anchors for the behaviors we want to preserve.

Key innovations include:
- Using simulation Q-values as anchors for performance metrics
- Multi-objective optimization to balance adaptation and retention
- Integration with on-board inference for real-time control

Initial results demonstrate the power of this approach:
- 50% reduction in power consumption while maintaining stable flight
- Preservation of critical behaviors while adapting to real-world conditions
- Successful validation in both sim-to-sim and sim-to-real scenarios
- Development of open-source firmware for practical deployment

Importantly, this work addresses both #behavioral (see @def-behavioral) through Q-value anchoring and #resource (see @def-resource) through reduced power consumption and hardware stress. This demonstrates how properly preserving learned behaviors can simultaneously improve multiple aspects of deployment performance.

This work demonstrates another key principle of expressive reinforcement learning: sometimes objectives are better preserved by directly optimizing them rather than trying to re-learn them through reward engineering. 