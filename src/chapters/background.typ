#import "../lib_cv.typ": primary_color, long_line, diamond, fonts
#import "@preview/cetz:0.3.1"

= Background and Literature Review

== Standard Fundamentals

#let state_color = primary_color
#let action_color = blue.darken(20%)

// Define colored math variables
#let st = text(fill: state_color)[$s_t$]
#let stp1 = text(fill: state_color)[$s_{t+1}$]
#let S = text(fill: state_color)[$S$]
#let a = text(fill: action_color)[$a$]
#let at = text(fill: action_color)[$a_t$]
#let A = text(fill: action_color)[$A$]

=== Markov Decision Processes
The standard formalization of sequential decision making, defined by a tuple (#S, #A, P, R, gamma), where #S is the state space, #A is the action space, P(#stp1|#st,#at) defines state transition probabilities, R(#st,#at,#stp1) specifies rewards, and $gamma$ is a discount factor. In robot learning, states typically represent sensor readings and physical configurations, while actions correspond to motor commands.

#figure(
  cetz.canvas({
    import cetz.draw: *
    
    // Global styling variables for consistent appearance
    let space_length = 2        // length of space lines (used by both space and bell)
    let delimiter_length = 0.2   // half-length of delimiter lines
    let tick_length = 0.1       // half-length of tick marks
    let label_offset = 0.3      // vertical offset for labels
    let thick_stroke = 0.8pt    // thickness for main lines
    let thin_stroke = 0.2pt     // thickness for fill lines
    let action_color = blue.darken(20%)  // color for action space elements
    
    // Function to draw a delimited space with label and tick
    let draw_space(pos, length, space_label, point_label, tick_pos, angle: 0deg, color: primary_color) = {
      // Helper function to rotate a point around pos
      let rotate(point, center: pos) = {
        let dx = point.at(0) - center.at(0)
        let dy = point.at(1) - center.at(1)
        let new_x = center.at(0) + dx*calc.cos(angle) - dy*calc.sin(angle)
        let new_y = center.at(1) + dx*calc.sin(angle) + dy*calc.cos(angle)
        (new_x, new_y)
      }
      
      // Calculate rotated endpoints for main line
      let end = rotate((pos.at(0), pos.at(1) + length))
      
      // Draw the main line
      line(
        pos,
        end,
        stroke: (paint: color, thickness: thick_stroke)
      )
      
      // Add delimiters at start
      let delim_start1 = rotate((pos.at(0) - delimiter_length, pos.at(1)))
      let delim_start2 = rotate((pos.at(0) + delimiter_length, pos.at(1)))
      line(
        delim_start1,
        delim_start2,
        stroke: (paint: color, thickness: thick_stroke)
      )
      
      // Add delimiters at end
      let delim_end1 = rotate((pos.at(0) - delimiter_length, pos.at(1) + length))
      let delim_end2 = rotate((pos.at(0) + delimiter_length, pos.at(1) + length))
      line(
        delim_end1,
        delim_end2,
        stroke: (paint: color, thickness: thick_stroke)
      )
      
      // Add space label
      content(
        (pos.at(0) + label_offset * calc.cos(angle - 90deg),
         pos.at(1) + label_offset * calc.sin(angle - 90deg)),
        text(fill: color, space_label),
        anchor: "center"
      )
      
      // Add tick mark at specified position
      let tick_y = pos.at(1) + length*tick_pos
      let tick_pos = rotate((pos.at(0), tick_y))
      let tick1 = rotate((pos.at(0) - tick_length, tick_y))
      let tick2 = rotate((pos.at(0) + tick_length, tick_y))
      line(
        tick1,
        tick2,
        stroke: (paint: color, thickness: thick_stroke)
      )
      
      // Add dot and label for sampled point
      if point_label != none {
        circle(
          tick_pos,
          radius: 0.05,
          stroke: none,
          fill: color
        )
        content(
          (tick_pos.at(0) + 0.3, tick_pos.at(1)),
          text(fill: color, point_label),
          anchor: "center"
        )
      }
    }
    
    // Function to draw a bell curve with delimiters
    let draw_bell(pos, width, label, color: primary_color) = {
      // Bell curve specific parameters
      let steps = 40            // number of steps for curve resolution
      let height = 1.2          // maximum height of bell curve
      let spread = 7            // controls width of bell curve (higher = narrower)
      
      let bell(x) = height*calc.exp(-spread*x*x)
      
      // Draw vertical lines for fill
      for i in range(steps + 1) {
        let x = -width/2 + width*i/steps
        let h = bell(x)
        line(
          ((pos.at(0) - h, pos.at(1) + x)),
          ((pos.at(0), pos.at(1) + x)),
          stroke: (paint: color, thickness: thin_stroke)
        )
      }
      
      // Draw curve outline
      line(..(
        for i in range(steps + 1) {
          let x = -width/2 + width*i/steps
          ((pos.at(0) - bell(x), pos.at(1) + x),)
        }
      ), stroke: (paint: color, thickness: thick_stroke))
      
      // Add delimiters that extend in both directions
      line(
        ((pos.at(0) - delimiter_length, pos.at(1) - width/2)),
        ((pos.at(0) + delimiter_length, pos.at(1) - width/2)),
        stroke: (paint: color, thickness: thick_stroke)
      )
      line(
        ((pos.at(0) - delimiter_length, pos.at(1) + width/2)),
        ((pos.at(0) + delimiter_length, pos.at(1) + width/2)),
        stroke: (paint: color, thickness: thick_stroke)
      )
      
      // Add label at the bottom
      content((pos.at(0), pos.at(1) - width/2 - label_offset), text(fill: color, label))
    }
    
    // Function to draw a transition arrow with optional label
    let draw_transition(start, end, label: none, label_pos: none, dashed: false, is_policy: false) = {
      line(
        start,
        end,
        mark: (end: "stealth"),
        stroke: (paint: if is_policy { primary_color } else { black }, thickness: 0.8pt, dash: if dashed { "dashed" } else { none })
      )
      if label != none and label_pos != none {
        content(label_pos, label)
      }
    }
    
    // Set up the layout
    let s = (0, 0)     // initial state position
    let d = (6, 0)     // distribution center position
    let a = (3, 1.5)   // action position
    
    let line_length = 2
    
    // Draw the diagram components
    
    // 1. Initial state space (horizontal)
    draw_space((s.at(0) - 3, 0), space_length, $S$, $s_t$, 0.3)
    
    // 2. Policy arrow and action distribution (vertical)
    let tick_pos = (s.at(0) - 2 + space_length*0.3, 0.3)  // Calculate tick position
    draw_transition(
      tick_pos,  // from s_t tick position
      ((s.at(0) - 1.7, 1.5)),   // to tip of action distribution
      label: $pi(a_t|s_t)$,
      label_pos: (s.at(0) - 1.2, 1.0),
      is_policy: true
    )
    
    // Draw vertical bell curve for action distribution
    let bell_pos = (s.at(0) - 0.5, 1.5)
    draw_bell(bell_pos, space_length, A, color: action_color)
    
    // Add sampling arrow (dashed) and action space
    let action_space_pos = (bell_pos.at(0) + 2, 0)  // Move action space to after bell curve
    draw_transition(
      (bell_pos.at(0), bell_pos.at(1) - space_length/2),  // from bottom of distribution
      action_space_pos,                                    // to sampled point
      dashed: true
    )
    
    // Draw action space with sampled point
    draw_space(action_space_pos, space_length, A, $a_t$, 0.5, color: action_color)
    
    // Draw transition arrows
    draw_transition(
      ((s.at(0) + 0.2, 0.3)),
      ((d.at(0) - 1.7, 0.3)),
      label: $P(s_{t+1}|s_t,a_t)$,
      label_pos: (2.5, 0.6)
    )
  }),
  caption: [The Markov Decision Process showing how a state #st in the state space #S and action #at = $pi(#st)$ determine the probability distribution $P(#stp1|#st,#at)$ over next states.]
)

=== Policies and Returns
A policy $pi(#at|#st)$ defines the probability of taking action #at in state #st. The goal in RL is to find a policy that maximizes expected returns, defined as the discounted sum of rewards: $E[sum gamma^t R(#st,#at,#stp1)]$. The discount factor $gamma$ determines how much to prioritize immediate versus future rewards.

=== Value Functions and Q-Functions
A value function $V^pi(#st)$ represents the expected return when following policy $pi$ from state #st. Similarly, a Q-function $Q^pi(#st,#at)$ represents the expected return when taking action #at in state #st and then following $pi$. These functions are central to our work in two key ways:
1. As a basis for objective composition in AQS, where normalized Q-values enable intuitive specification of behavioral trade-offs
2. As anchors for domain transfer, where simulation Q-values preserve critical behaviors during real-world adaptation

=== Multi-Objective RL
Multi-objective reinforcement learning extends the standard MDP framework to handle multiple reward signals simultaneously. Instead of a single scalar reward R, the agent receives a vector of rewards $vec(R)$ corresponding to different objectives. This introduces the challenge of balancing competing objectives and finding Pareto-optimal policies that make principled trade-offs between different goals.

=== Sim-to-Real Transfer
The process of deploying policies trained in simulation to real-world systems, encompassing both the technical challenges of domain adaptation and the practical constraints of physical deployment. This fundamental concept bridges the gap between idealized training environments and the complexities of real-world operation.

== Introduced Conceptual Framework
=== Core Concepts
==== The Intent-to-Behavior Gap
The fundamental challenge of translating a practitioner's intended policy behavior into a mathematical specification that reliably produces that behavior when optimized. This gap exists in any reinforcement learning system, as practitioners must convert high-level intentions (like "move smoothly and efficiently") into concrete optimization objectives. Traditional approaches leave practitioners to define scalar rewards and combine objectives through linear scalarization, which often fails to capture the nuanced relationships between different behavioral aspects. More sophisticated specification techniques, such as algebraic composition methods or formal logic frameworks, aim to minimize this gap by providing principled tools for expressing behavioral requirements.

==== The Intent-to-Reality Gap
A compound challenge in robot learning that combines the intent-to-behavior gap (the challenge of specifying desired behaviors through mathematical objectives) with the sim-to-real gap (the challenge of preserving these behaviors during real-world deployment). This gap represents the full distance between a practitioner's intentions and the actual behavior of deployed systems, making it a central challenge in practical robot learning.

==== Expressive Reinforcement Learning
A subfield of reinforcement learning focused on minimizing the intent-to-behavior gap through principled frameworks for objective specification and composition. Key aspects include:
1. Algebraic approaches to objective composition that maintain semantic meaning (e.g., using power-mean operators for intuitive combination of Q-values)
2. Formal methods for specifying policy behaviors (e.g., temporal logic for constraint specification)

The key distinction from traditional multi-objective RL is the focus on providing practitioners with intuitive, mathematically grounded tools for expressing how objectives should be combined, rather than just identifying Pareto-optimal policies.

==== Behavioral Retention
#label("def-behavioral")
The degree to which a policy maintains its learned behaviors when transferred to new domains or adapted to new conditions. We quantify this through multi-objective evaluation of Q-values across domains, particularly focusing on performance in critical scenarios that may occur rarely but have high importance. This provides a more nuanced view than traditional average-case metrics.

=== Mathematical Framework
==== Power-Mean as a Logical Operator
#align(center)[
  $M_p(Q_1, Q_2) = ((Q_1^p + Q_2^p)/2)^(1/p)$ <power-mean>
]
A fundamental operator for composing objectives, where parameter $p$ controls the logical behavior: as $p -> -infinity$, $M_p$ approaches MIN (AND), and as $p -> infinity$, it approaches MAX (OR). This provides a continuous spectrum between AND and OR operations, enabling flexible composition of objectives while maintaining bounded outputs.

==== Behavioral Objectives
We use this term to encompass both the high-level intentions a practitioner wants to achieve and their formal expression as optimization targets. Our work demonstrates this through several key examples: smooth motor control achieved through temporal and spatial action similarity in CAPS, preservation of critical scenario performance through Q-value anchoring, resource efficiency through architectural optimization, and complex objective composition through algebraic Q-value operations in AQS. This structured approach distinguishes our objectives from simple reward functions, emphasizing their principled nature and composability.

=== Evaluation Metrics
==== Policy Smoothness
A quantitative measure of a controller's action stability over time, capturing both temporal consistency and spatial coherence. Our work introduces principled metrics for measuring smoothness through frequency analysis of control signals and state-action mapping continuity, enabling objective comparison of different control approaches. This addresses a critical gap in the field where smoothness was previously assessed through ad-hoc or qualitative methods.

== Related Work

This section reviews key developments in reinforcement learning that address the intent-to-reality gap in robot learning, organized around three fundamental challenges: objective specification, sim-to-real transfer, and efficient deployment.

=== Objective Specification and Composition
Traditional reinforcement learning approaches rely heavily on manual reward engineering @tokamak, which often fails to capture complex behavioral requirements. Several approaches have emerged to address this:

==== Multi-Objective RL
Classical approaches focus on finding Pareto-optimal policies @alegre2023sample for competing objectives, but often lack intuitive ways to specify trade-offs @NFv2. These methods typically rely on linear scalarization or constrained optimization, which can be limiting when objectives have complex interactions.

==== Formal Methods
Temporal logic frameworks @NFThesis and propositional logic approaches @Wingate_Temporal_MORL provide rigorous specifications but can be challenging for practitioners to use effectively. Recent work has explored more accessible formal methods that maintain mathematical rigor while improving usability.

==== Expressive RL
Recent work has explored algebraic approaches to objective composition @NFv2 and structured reward design @Sim2multi that maintain semantic meaning. These methods provide practitioners with intuitive tools for specifying how objectives should be combined, going beyond simple linear composition.

=== Sim-to-Real Transfer
The challenge of transferring policies from simulation to reality remains central to practical robot learning @NFori. Current approaches broadly fall into two categories:

==== Environment-Focused Methods
Domain randomization @Sim2multi and adaptive architectures @Hwangbo2017ControlOA attempt to bridge the reality gap through robust training. However, these approaches often struggle with accurately modeling complex real-world dynamics @PasikDuncan1996AdaptiveC.

==== Policy-Focused Methods
While fine-tuning approaches can adapt to real systems, they struggle with catastrophic forgetting @catastrophic-forgetting-wolczyk, where policies maintain high rewards on common scenarios but fail on rare, critical cases @catastrophic-forgetting-binici. Recent work has shown that structured training environments @NFori and multi-objective optimization across domains @Muratore2022 can help maintain critical behaviors.

=== Efficient Deployment
Practical deployment requires policies that are efficient in both computation and physical resource usage @NFThesis. Three key areas have emerged:

==== Control Optimization
Explicit regularization @NFThesis and adaptive control methods @model_quad_adapt help maintain smooth and efficient behavior. This builds on classical work in optimal control @benchmarkingRobo, while addressing the unique challenges of learned policies.

==== Architectural Efficiency
Recent advances in asymmetric actor-critic methods @islam2017reproducibility and network compression @Han2016DeepCC demonstrate that smaller networks can achieve comparable performance. Liquid neural networks @hasani2021liquid show promise for adaptive control with reduced model complexity.

==== Resource-Aware Design
Joint optimization of computational and physical efficiency @Hwangbo2017ControlOA has become crucial for practical robotics, particularly in embedded systems @Chinchali2021 where network dependencies can limit autonomy.

=== Open Challenges 
Several fundamental challenges remain in bridging the intent-to-reality gap:

1. *Objective Specification:* While formal methods and expressive frameworks provide tools for composition @NFv2, specifying complex objectives in a way that reliably produces intended behaviors remains difficult @alegre2023sample.

2. *Behavioral Guarantees:* Current approaches lack formal guarantees about behavioral preservation @catastrophic-forgetting-binici, particularly for safety-critical scenarios. This limits deployment in high-stakes applications where performance bounds are required.

This dissertation addresses these challenges through a unified approach that combines expressive objective specification with robust transfer and efficient deployment. Through frameworks like AQS, CAPS, and Anchor Critics, we demonstrate how structured approaches to reinforcement learning can minimize the intent-to-reality gap in practical robot learning. 

=== stub <def-resource>