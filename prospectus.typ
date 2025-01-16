/*
Format Specifications:
- Length: 10 single-spaced pages or 20 double-spaced pages
- Font: 11 or 12-point
- Margins: 1-inch all around
- Bibliography excluded from page limit

Required Components:

Title Page
- Name and contact information
- Research title
- Committee members (minimum 3 readers, first reader must be CS faculty)
- Date

Abstract (350-word)
- Intent-to-reality gap in robot learning
- Expressive RL as solution
- Key frameworks and results

Main Body:

1. Problem Statement and Objectives
   - The Intent-to-Reality Gap
     - Historical context (brittle rewards, sim-to-real issues)
     - Current limitations in practice
   - Our Approach: Expressive Reinforcement Learning
     - Key insights from preliminary work
     - Framework overview
   - Research Objectives
     1. Structured Objective Specification
     2. Intention-Preserving Transfer
     3. Resource-Aware Control
     4. Practical Validation

2. Background and Literature Review
   - Standard Fundamentals
     - Markov Decision Processes
     - Policies and Returns
     - Value Functions and Q-Functions
     - Multi-Objective RL
     - Sim-to-Real Transfer
   - Introduced Conceptual Framework
     - Core Concepts
       - The Intent-to-Behavior Gap
       - The Intent-to-Reality Gap
       - Expressive Reinforcement Learning
       - Behavioral Retention
     - Mathematical Framework
       - Power-Mean as a Logical Operator
       - Behavioral Objectives
     - Evaluation Metrics
       - Policy Smoothness
   - Related Work
     - Objective Specification and Composition
       - Multi-Objective RL
       - Formal Methods
       - Expressive RL
     - Sim-to-Real Transfer
       - Environment-Focused Methods
       - Policy-Focused Methods
     - Efficient Deployment
       - Control Optimization
       - Architectural Efficiency
       - Resource-Aware Design
     - Open Challenges

3. Published Results
   - Foundations: How to Train Your Quadrotor
     - The RE+AL Framework
     - First RL to outperform PID
     - Initial insights into objective specification
     - Systems Implementation
       - Real-time control architecture
       - Hardware integration on real drones
       - Performance validation
   
   - Resource-Aware Control: CAPS
     - Principled approach to smooth control
     - Temporal and spatial smoothness theory
     - 80% power reduction results
     - Impact on real-world deployment
   
   - Efficient Neural Architectures
     - Actor-critic asymmetry for deployment efficiency
     - 99% reduction in actor size
     - Validation across multiple algorithms

4. Proposed Methodology
   - Structured Objective Specification (AQS)
     - Preliminary Results
       - Novel domain-specific language design
       - Power-mean operators and Q-value normalization
       - 600% improvement in sample efficiency
     - Future Development
       - Formal semantics and verification
       - Safety constraint integration
       - Theoretical guarantees
   
   - Intention-Preserving Transfer (Anchor Critics)
     - Current Results
       - Multi-objective Q-value optimization
       - Preventing catastrophic forgetting
       - Systems Implementation
         - SWANNFlight firmware development
         - On-board inference optimization
     - Reframing and Positioning
       - Connection to objective specification frameworks
       - Relationship to behavioral cloning approaches
       - Integration with system identification literature
       - Broader impact on sim-to-real methods
   
   - Objective Composition and Validation
     - Theoretical Integration
       - Unifying Q-value based objectives
       - Compositional properties
       - Theoretical guarantees
     - Validation Methods
       - Behavioral verification metrics
       - Trade-off preservation analysis
       - Compositional property validation

5. Timeline and Milestones
   - January 2024: AQS paper (ICML)
   - February-March 2024: Begin dissertation
   - February 2025: Anchor Critics paper
   - March-April 2025: Complete dissertation

6. Bibliography
*/

#import "src/lib_cv.typ": primary_color, long_line, diamond, fonts
#import "@preview/cetz:0.3.1"

#set document(title: "From Intent to Reality: Finding Faithful Policies through Expressive Specifications")

#set page(
  width: 8.5in,
  height: 11in,
  margin: (x: 1in, y: 1in),
  footer: context [
    #if counter(page).at(here()).first() != 1 {
      align(center, text(fill: primary_color, size: 14pt)[#counter(page).display()])
    }
  ]
)

#set text(
  font: "New Computer Modern",
  size: 11pt,
  hyphenate: false
)

#set heading(numbering: "1.1")

#show heading.where(level: 1): it => [
  #long_line
  #set text(fill: primary_color, weight: "bold", size: 17pt)
  #it
  #v(0.7em)
]

#show heading.where(level: 2): it => [
  #set text(fill: primary_color.lighten(20%), weight: "medium", size: 16pt)
  #it
]

#show heading.where(level: 3): it => [
  #set text(fill: primary_color.lighten(30%), weight: "medium", size: 13pt)
  #it
  #v(0.3em)
]

#show heading.where(level: 4): it => {
  v(0.5em)
  box(inset: (right: 0.1em, bottom: 0em))[#text(weight: "bold", it)]
  box(inset: (right: 0em, bottom: 0em))[#text(weight: "bold", ":")]
}

#show ref: it => {
  if it.element != none and it.element.func() == heading {
    if it.element.level == 4 {
      link(it.element.location(), [(Def #numbering(
        it.element.numbering,
        ..counter(heading).at(it.element.location())
      ))])
    } else {
      it
    }
  } else {
    it
  }
}

#set par(
  justify: true,
  leading: 0.8em,
)

#set math.equation(numbering: "(1)")

// Document content begins here

// At the start of the document
#let behavioral = "behavioral retention"
#let resource = "resource efficiency"

// Title Page
#align(center, stack(
  spacing: 0pt,
  text(size: 18pt)[*BOSTON UNIVERSITY*],
  v(0.2fr),
  text(size: 14pt)[GRADUATE SCHOOL OF ARTS AND SCIENCES],
  v(0.6fr),
  text(size: 14pt)[A Prospectus for Ph.D. Dissertation],
  v(0.6fr),
  text(size: 25pt)[*Minimizing the Intent-to-Reality Gap*],
  v(0.3fr),
  text(size: 14pt)[By],
  v(0.3fr),
  text(size: 18pt)[*BASSEL EL MABSOUT*],
  v(0.6fr),
  
  text(size: 12pt)[
    Submitted in Partial Fulfillment of the\
    Requirements for the Degree of\
    Doctor of Philosophy\
    In the Department of Computer Science
  ],
  v(0.6fr),
  
  text(size: 14pt)[COMMITTEE MEMBERS:],
  v(0.3fr),
  text(size: 14pt)[*DR. RENATO MANCUSO*] + text(size: 14pt, style: "italic")[ First Reader],
  v(0.2fr),
  text(size: 14pt)[*DR. SABRINA NEUMAN*],
  v(0.2fr),
  text(size: 14pt)[*DR. KATE SAENKO*],
  v(0.2fr),
  text(size: 14pt)[*DR. BINGZHUO ZHONG*],
  v(0.6fr),
  
  text(size: 12pt)[January 15, 2025]
))

#pagebreak()

#include "src/chapters/abstract.typ"
#pagebreak()

// Table of Contents
#outline(
  title: "Contents",
  indent: true,
  depth: 2
)
#pagebreak()

#include "src/chapters/problem_statement.typ"
#include "src/chapters/background.typ"
#include "src/chapters/published_results.typ"
#include "src/chapters/current_work.typ"
// #include "src/chapters/methodology.typ"
#include "src/chapters/timeline.typ"

#bibliography("megaref.bib")
