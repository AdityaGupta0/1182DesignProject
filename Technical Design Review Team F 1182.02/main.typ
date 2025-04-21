#set align(center)
#set text(28pt,font: "Source Serif Pro")
#linebreak()
#parbreak()
Quantifi Inventory Tracking System
#parbreak()
#line()

#set text(20pt)
Technical Design Review
#linebreak()
#parbreak()

#parbreak()
#linebreak()
#set text(18pt)
Team F
#set text(14pt)
\
Aditya Gupta\
Georgia Stone\
Adeel Khatri \
#linebreak()
#parbreak()
#set text(16pt)
1182.02 (8076) \
Dr. Bailey Braaten \
#datetime.today().display() \


#pagebreak()
#set text(10pt)
#set page(
  paper: "a4",
  header: [  
    #set text(10pt)
    #smallcaps[Technical Design Review]
    #h(1fr) _Team F_
  ],
  margin: auto,
  numbering: "1 / 1",
)
#set text(12pt)
#set align(left)


//chapter formatting
#let chapter = figure.with(
  kind: "chapter",
  // same as heading
  numbering: none,
  // this cannot use auto to translate this automatically as headings can, auto also means something different for figures
  supplement: "Chapter",
  // empty caption required to be included in outline
  caption: [],
)

// emulate element function by creating show rule
#show figure.where(kind: "chapter"): it => {
  set align(left)
  set text(22pt)
  counter(heading).update(0)
  if it.numbering != none { strong(it.counter.display(it.numbering)) } + [ ] + strong(it.body)
}

// no access to element in outline(indent: it => ...), so we must do indentation in here instead of outline
#show outline.entry: it => {
  if it.element.func() == figure {
    // we're configuring chapter printing here, effectively recreating the default show impl with slight tweaks
    let res = link(it.element.location(), 
      // we must recreate part of the show rule from above once again
      if it.element.numbering != none {
        numbering(it.element.numbering, ..it.element.counter.at(it.element.location()))
      } + [ ] + it.element.body
    )

    if it.fill != none {
      res += [ ] + box(width: 1fr, it.fill) + [ ] 
    } else {
      res += h(1fr)
    }

    res += link(it.element.location(), (it.page))
    strong(res)
  } else {
    // we're doing indenting here
    h(1em * it.level) + it
  }
}

// new target selector for default outline
#let chapters-and-headings = figure.where(kind: "chapter", outlined: true).or(heading.where(outlined: true))

//
// start of actual doc prelude
//
#v(2pt)
#set heading(numbering: "1.A.I")
#outline(target: chapters-and-headings, title:"Table of Contents",depth: 2)
// can't use set, so we reassign with default args
//#let chapter = chapter.with(numbering: "I")

// an example of a "show rule" for a chapter
// can't use chapter because it's not an element after using .with() anymore
//#show figure.where(kind: "chapter"): set text(red)
#show figure.caption: set text(10pt)
//
// start of actual doc
//

//#set caption(text(size: 10pt))
#pagebreak()
//end of prelude

#chapter("Executive Summary ")
This report follows the semester-long design project as part of the team's ENGR 1182.02 Fundamentals of Engineering course. Through discussions and research, the team identified the task of inventory management in restaurants as a field of focus. 

The team researched the task of inventory management, the difficulties, and the current solutions. The team also interviewed an individual affected by this issue to gain a personal perspective. Using this data, the team organized the results into a variety of formats to visualize, analyze, and understand the current state of the market and potential value propositions. From this, the team learned that inventory management is a multifaceted, complicated mission critical task, and current solutions all had significant tradeoffs/drawbacks. Using all this research, the team established a focus on making an inventory solution that combined convenience and accuracy while not being prohibitively expensive or hard to setup.

Equipped with a design focus, the team brainstormed multiple concepts to solve the issue. These ranged from smart containers that used sensors to sense ingredients or dispensers that track item usage. All of these solutions, however, are integrated with software to interface with the end-user. For this reason, the concept development of the hardware and software was branched apart. After sufficient concepts were established, the team analyzed each one by comparing pros/cons, user feedback, and Pugh scoring matrices based on user needs. Concepts were down-selected based on this analysis until only one hardware and software concept remained. 

The remaining hardware and software concepts were refined and merged into a single grand concept design. This grand concept is a modular smart pad system that detects the weight of items and correlates it using an RFID tag before uploading it to a web-app that an end-user can access to track inventory. The team then explored the possible usage of the grand concept along with anticipated challenges and market viability, finding that the grand concept had high potential.

A prototype was then constructed by establishing requirements based on user needs. The prototype had simplified many of the goals of the grand concept. The prototype was tested, passing all validation tests and assessments with flying colors.

Potential end users were interviewed based on the prototype and grand concept design to determine if they had an interest in a potential product. The results were favorable and indicated strong market interest. 

To bring the Quantifi system to market, the team will need additional funding for research and development of the grand concept design, and significant monetary investment to build the first systems to deploy to restaurants across the world. With proper support, the Quantifi system can eliminate the perils of inventory management.






#pagebreak()
#chapter("Problem Definition Review")
= Introduction
This report is a technical design review exploring the development of a solution for restaurant inventory management. This issue was identified by team members interviewing people around them to identify problems they dealt with on a daily basis. Restaurant inventory management is an arduous but necessary task for all food service establishments, and tools to improve the efficiency of associated tasks are in high demand.

By conducting further interviews and research, the team explores the market of current solutions, identifies current alternatives, and creates a design with a potential competitive edge that would solve the issues of restaurant inventory management. 

This report is part of the team's ENGR 1182.02 Fundamentals of Engineering course, where the team embarks on a semester-long design project. The goal is to develop a design that could be manufactured, marketed, and sold as a real product to solve an issue. 


= Problem Definition
== User Persona
Below in @graphicaluserpersona, is a fictional example of a possible member of the target audience of the project based on real-world information. Albert is a South Asian chef who, apart from cooking, is responsible for acquiring and stocking ingredients. 
#figure(image("graphicaluserpersona.svg"),
  caption: [Graphical User Persona of a theoretical end-user.]
) <graphicaluserpersona>

== Tasks & Pains
*Task 1:* Keeping track of ingredient stock \
*Associated Pains:*
+ It is tedious and time-consuming to check the quantity of every ingredient.
+ Taking inventory manually is generally an opening or closing activity, which leaves a large amount of time for things to go out of stock mid-day
+ Taking accurate inventory of many ingredients is difficult due to their form, size, weight, and/or container. 
+ Tracking produce expiry and freshness is difficult due to inconsistent labeling and physical shifting of produce.
+ Depending on where inventory is tallied, it can be difficult to check stock (especially when not in-store) quickly. Also, if the inventory is done on paper, restaurant managers risk damaging or losing their records.

*Task 2:* Ordering ingredients\
*Associated Pains:*
+ Communicating with wholesalers and vendors about what is needed and the time frame required for delivery is difficult, especially since different traders use different platforms and means of contact (e.g. some use websites while others require phone calls or order sheets).
+ Knowing what to order can be difficult. If an ingredient is running low, deciding when exactly more should be ordered so that there aren't excess ingredients idling is a pain.  
+ Different vendors have different fulfillment times for different produce which must be considered when ordering in advance. 
+ Paper order forms can be lost easily and may require long transit times
+ Digital order forms are cumbersome to work on for those who aren't experts in spreadsheets.


= Research Plan //REVIEW AND EDIT
The research the team plans on conducting is meant to further knowledge of potential end users to understand the exact pain points of the selected user group. From here, the team also plans on applying its research to create actionable steps to design a solution. The plan is to focus most research on the restraint side of the tasks, rather than those relating to home cooking, as there is more data available, and the home tasks are often a subset of the issues a commercial restaurant would face. The team intends to use a combination of qualitative and quantitative data, not only from sources and datasets readily available online, but also from local establishments that may be in a similar situation to the user persona described above. 

Noting @researchplantable, the team seeks insight into mainly large-scale establishments and restaurants, but some questions (like Q2, Q3, and Q5) can be rephrased such that insight is gained from families, home settings, and small commercial kitchens as well. The questions relate to inventory tracking, noting what technology exists in the current market relating to the pains, and seeing what factors affect the decisions of the selected user group.

The research plan and data collection process are bound to certain ethical considerations, mainly the following. Primarily, all data collected is be done with consent from participants, either in the form of an interview or surveys; consent is explicitly gained before collecting any data. Additionally, data is collected in such a way that interviewees remain anonymous, as to respect the privacy of the institutions and individuals that are involved. This can be done by isolating the data collected from and affiliation to individuals/institutions. Similarly, within the described bounds, the data collected remains secure. Lastly, data is collected with voluntary participation and complete transparency with the individuals. Participants are not coerced or required by any means to answer any questions, and the purpose of the study is communicated before any data is collected. This includes communicating how the research may provide benefit, and in what ways it might be limited. 


#show figure.where(
  kind: table
): set figure.caption(position: top)
#figure(
  table(
    columns: (auto, auto, auto),
    table.header(
      [*Research Question (RQ)*],[*Qualitative Data Collection*],[*Quantitative Data
  Collection*]
    ),
    [*RQ1* What are methods to take inventory of spices/powdered substances?], 
    [Manual inventory by weight or using Point Of Service (POS) systems. @noauthor_restaurant_nodate],
    [51% of restaurants in the U.S. use cloud-based POS systems to track inventory usage. @noauthor_us_nodate],
    [*RQ2* What are methods to take inventory of liquid food items (e.g. milk. sauces, etc.)?],
    [Manual inventory by weight or container measurement. Or using POS systems. @noauthor_food_nodate],
    [12% of bars use gauged dispensers to track liquid asset consumption.@noauthor_guide_nodate],  
    [*RQ3* What are methods to take inventory of whole items (e.g. whole fruit, vegetables, poultry)?],
    [Manual inventory (by weight,  container, or count), RFID, Barcodes, or POS systems. @jenkins_ultimate_nodate],
    [93% of retailers use RFID in some capacity for asset tracking. @noauthor_new_nodate],
    [*RQ4* How do restaurants stock their kitchens?],
    [Restaurant owners network with other restaurants or utilize online marketplaces to find reliable bulk sellers. @noauthor_where_nodate],
    [39% of local food is sold through intermediate institutions, and 27% is sold through retailers. @noauthor_local_nodate],
    [*RQ5* How can restaurants sort perishables and keep track of expiry dates /freshness?],
    [Labeling all shipped products with perishing dates, using the FIFO (first-in, first-out) method. Barcodes and RFID tags can be used instead of date labels. @noauthor_food_2023],
    [4-10% of food shipped to restaurants is discarded before it’s served to customers due to excess inventory or improper storage.@mettler_food_2023],
    [*RQ6* How do larger restaurants work with suppliers to stock frequently ordered goods?],
    [Proactive communication (using timely inventory data) and recurring pre-scheduled orders based on prior data and consumption rates. @noauthor_5_nodate],
    [On average, up to 6% of all food acquired by restaurants is wasted /thrown away @mettler_food_2023],
    [*RQ7* What tasks and pains do wholesalers have when it comes to handling and fulfilling orders?],
    [Disruptions in the supply of raw materials can delay the shipping of products.@harichandan_top_nodate],
    [88% of interviewed companies experience shipping delays, and 70% experience product shortages. @gatti_supply_2021]
  ),
  caption: [Research Plan]
) <researchplantable>


= Research Results
== Task
The focus task to be analyzed as the result of prior research is inventory management and the ordering of food service ingredients for small to medium-sized restaurants. 

== Pains 
Based on the research conducted in @researchplantable and prior information, the team identified the following primary pains associated with inventory management in restaurants.
- Tracking/taking inventory is tedious, time-consuming, and costly @noauthor_5_nodate.  
- Manual inventory can be inaccurate and/or unreliable @noauthor_food_2023.
- Overstocking to mitigate shortages combined with imprecise inventory can lead to food wastage @mettler_food_2023.
- Long-term trend/statistic tracking is difficult since data is often disorganized and have differing units @jenkins_ultimate_nodate.
- Vendors have differing protocols and lead times for orders, which can be hard to keep track of @kowalewski_guide_2023.
All in all, these pains stem from the unreliability of manual inventory along with the tedious nature of the tasks involved. Additionally, these pains often have monetary costs associated, such as labor costs and fees for shorter lead times when ordering from wholesalers, which amplify the pains. Restaurant managers need a solution to save their business both time and money. 

== Gains 
Solving the issues listed above could result in the following gains:
- Reduced food wastage 
- More available time for miscellaneous tasks
- Vendors clearly understand what they are expected to deliver and have ample time to do so
- Reduced operating costs
- increased confidence in operations and reduced stress
Overall, these gains stem from the time saved from restaurants not having to do manual inventory which is an arduous and unreliable process. Additionally, data analysis of real-time inventory would open the door for proactive and predictive ordering with a lower risk of overstocking/wastage. This would prevent ingredients from running out, which is advantageous for consumers, vendors, and restaurant managers.  

== User Needs
_In order of predicted importance_
+ Affordable - Low initial and operating costs of the system and all supporting elements (including labor). @mettler_food_2023
+ Convenient - Automates as many tasks as possible with a simple learning curve. Does not require expertise in any particular field and can be used by anyone who could work in a restaurant. Generally simple to use.
+ Connectivity - Digital communication and storage to ensure high availability, reliability, and streamlined communication with vendors. @gatti_supply_2021 
+ Easy to implement - Can be simply retrofitted/implemented in most common restaurant kitchens without disrupting the environment significantly.
+ Robust - Can reliably function in the often messy and high-contact environments found in a restaurant's kitchen.
+ Precise - frequent and accurate measurement of inventory. @jenkins_ultimate_nodate


#figure(
  image("pairwisecomparison.svg"),
  caption: [Pairwise Comparison Chart],
  kind: table
) <pairwisecomparison>

As shown in @pairwisecomparison above, the predicted importance of certain user needs disagrees significantly with the normalized pairwise comparison results in some instances. For example, affordability was predicted to be the most important, however, it sits in a middle ground. This outcome is understandable since if a solution can meet many of the other users' needs, a user is more likely to be willing to pay for the benefits.

Ease of implementation is the most important user need by far, which is logical since no matter how many advantages a possible solution has, if it is cumbersome to implement, it is likely to have a low adoption rate. 

The predicted values for precision, robustness, and connectivity were largely correct, as those were initially ranked as the bottom three in terms of importance. The final weighted ranking agrees with this assessment, as those three scored the lowest.  

== Stake Holders & Potential Impacts
*Users:*
- Restaurant owners/managers
  - Positive: Benefit from lower operating costs.
  - Positive: Easier job/ less tedious tasks related to inventory and ordering.
  - Positive: Better relationship with suppliers.
  - Positive: More time to focus on other managerial/business aspects besides acquisition and inventory. 

*Direct Stakeholders:*
- Restaurant staff
  - Positive: will not be delegated unenjoyable and tedious inventory tasks
  - Positive: not need to worry about making operation-critical mistakes on inventory
  - Negative: less jobs/roles
- Restaurant Chefs/cooks
  - Positive: satisfied with ever-present ingredients
- Patrons
  - Positive: pleased with lower chance of menu items being unavailable 
  - Positive: happy with possible lower menu prices due to lower operating costs
  - Positive: satisfied with a wide selection and palette of flavors that are not limited by acquisition difficulties


*Indirect Stakeholders:*
- Producers
  - Positive: Better awareness of production targets/goals
  - Positive: improved communication with vendors
  - Positive: less worrying about idle inventory
- Waste management
 - Positive: less food waste to collect
 - Negative: possibly reduce the viability of compost programs
 - Positive: reduce pickup weight and allow for more stops along collection routes if wide adoption reduces food waste output


*Others:* 
- Cloud providers
  - Positive: Increased subscribers/ increased revenue
  - Negative: increased load on servers
- IT Departments/ SaaS#footnote[Software as a Service] Managers
  - Negative: increased workload to maintain systems
  - Negative: more dependency and more responsibility
- Food Pantries
  - Negative: Less excess food donated from restaurants

== Market Size
In the US, there are approximately 357,000 restaurant managers, with the market expected to grow over the next decade @noauthor_job_nodate. As of 2020, there are over 426,000 small and medium-sized restaurants that are not part of any chain, with the industry growing year over year @noauthor_number_nodate. Based on these statistics, there is a massive domestic user base for inventory management systems. 

With the possible cost savings of a solution, larger national/international food chains would benefit from an improvement in stock tracking rather than brute force over-stocking, which is wasteful and costly @mettler_food_2023. Accounting for chain restaurants, the potential market size balloons to over a million restaurants @mccauley_restaurant_2024. Additionally, chains are likely to spread the adoption of a solution as they typically standardize equipment across locations @davis_importance_2018. 

== Current Alternatives
There are numerous inventory tracking systems designed for the food service industry. The primary methods are manual inventory, digital POS systems, vendor tracking, item tagging (RFID or barcode-based), and FIFO systems @jenkins_ultimate_nodate @noauthor_restaurant_nodate @noauthor_new_nodate. Both FIFO and manual inventory are entirely reliant on people and protocols, while the other three solutions are reliant on digital platforms that track consumption. 



#let a = table.cell(
  fill: green.lighten(60%),
)[#sym.checkmark]
#let b = table.cell(
  fill: red.lighten(60%),
)[#sym.crossmark]
#figure(
  table(
    columns: (auto,auto,auto,auto,auto,auto),
    table.header(
    [*User Need*], [*Manual Inventory*], [*Vendor Inventory*],
    [*POS System*], [*RFID/Barcode*], [*FIFO System*]
    ),
    [Affordable],[#b],[#a],[#b],[#a],[#a],
    [Precise],[#a],[#b],[#b],[#a],[#b],
    [Robust],[#b],[#b],[#a],[#a],[#a],
    [Easy to Implement],[#a],[#b],[#a],[#b],[#a],
    [Convenient],[#b],[#b],[#a],[#b],[#b],
    [Connectivity],[#b],[#a],[#a],[#a],[#b],
    //[Versatile],[#a],[#a],[#a],[#b],[#a],
  ),
  caption: [Competitive Matrix\ _Green cells with checks indicate the need is met by the alternative\ and red cells with crosses indicate the need is unmet by the alternative_],
) <compeitivematrix> 
//_Green cells with checks indicate the need is met by the alternative and red cells with crosses indicate the need is unmet by the alternative_
#parbreak()

As highlighted in @compeitivematrix, there is a large gap in convenient solutions. The only convenient solution is a POS system since it tracks inventory automatically based on orders. All other methods are tedious since they require some manual actions. 

Precision is another competitive gap among current popular solutions. The only solutions that are precise are manual inventory and tag tracking (RFID/Barcode), however, these methods come with caveats in their precision. Manual inventory can theoretically be very precise, but it is dependent on the effort put in by the employee taking inventory, and it is impractical for employees to be extremely precise when they have large quantities of items to inventory. Tag tracking systems are precise but lack granularity except for certain types of whole produce. 

Generally, all current alternatives are far from perfect, and even in the categories which certain solutions have advantages and meet user needs, they come with significant caveats. 

#linebreak()
= Value Proposition 
Busy restaurant owners find themselves struggling to manually track small, essential ingredients. A smart inventory management system is the solution and transforms the entire process. The team's inventory manager is designed for kitchens where spices and small commodities are used frequently and in inconsistent quantities. The inventory manager offers real-time connectivity to monitor inventory through an intuitive dashboard. Not only does this solution improve accurate tracking without the need for manual weighing/checks @noauthor_food_2023, but it also streamlines communication with suppliers through an integrated order generator. Accurate inventory data is shared with distribution managers, which ensures that reordering products is timely and precise, increasing the efficiency of the restaurant @noauthor_local_nodate. This direct connection between clients and distributors minimizes the possibility of running out of ingredients when they are needed most, therefore increasing the potential profit margins and enhancing customer satisfaction. By reducing unnecessary human interaction, like labor-intensive tasks and human error, an inventory monitoring system cuts costs, as well as optimizes stock levels. Collectively, restaurant owners can focus on what matters most, delivering exceptional experiences to customers, confident that they won’t need to stress about out-of-stock items. This inventory manager is the ideal solution for any establishment looking to modernize and optimize the inventory process, all while strengthening supplier relationships with effective information sharing @noauthor_where_nodate.

#linebreak()
= Design Focus //REWRITE or REVIEW/EDIT
An effective design would need to prioritize connectivity and direct communication with inventory suppliers to meet user needs. The design could maintain a competitive edge by being more precise and convenient than other options on the market, which ties in with stakeholder needs. The research stage has pushed the design to take these ideals more into consideration. Anticipating the user value of defined traits within @compeitivematrix made clear that there are significant gaps in user needs, which would allow a new solution to gain traction, and that users are willing to pay more for convenient solutions. 

The market gaps identified by the market character are precision and affordability, which help us shift focus from making a product with connectivity, which is already widespread in current alternatives, to a design focused on precision and simplicity. These findings encouraged the team to de-prioritize one-time user difficulties, such as the installation of a new product. Along with this, the team has a comprehensive understanding of the tasks/pains of the user group, where the scope of the solution has expanded from strictly the impact on restaurant managers to the impact on vendor-operator relationships. The wider the target audience, the more impactful the solution can be. 

#pagebreak()
#chapter("Concept Development Review")
= Concept Brainstorming and Ideation
== Process Description 
The team began the brainstorming process by reiterating the primary goal of the physical design, which is to measure the quantity of ingredients, particularly ones like spices, which are often difficult to measure. Additionally, the team identified the most important user needs based on the @pairwisecomparison, which was the convenience and ease of implementation. The team then created a list of quick ideas that would meet this goal, though whether or not the concepts were practical or feasible was not yet assessed. 

Once the team had generated every conceivable idea that would satisfy at least one user need, they began to eliminate ideas on the grounds of practicality. As a result, the team finished with a list of around seven ideas. From there, these ideas were discussed in detail, and team members would attempt to point out flaws and advantages. They also tried to determine if ideas were similar and could be combined into one concept. 

At this point, the team determined that the back-end application concept should be regarded as separate from the physical design concept, as different software designs would work interchangeably between physical designs since the only output of the physical design would be the quantities of measured ingredients. 

Once a satisfactory shortlist of just three ideas was reached, the team proceeded to flesh out the details of the concepts and begin sketches of the physical aspects and descriptions of the digital aspects. After the concepts had sufficiently matured, the team assessed each concept on its ability to meet to full breadth of user needs defined in @compeitivematrix. During discussions with potential end-users, however, the user need of affordability was discounted from the user needs we tried to meet as potential end-users agreed that additional cost is justified for added convenience. 

Finally, using the results of interactions with potential end users, the concepts were narrowed down to just two ideas, which were examined using a Pugh Scoring Matrix. The results of this comparison enabled the team to determine which concept to pursue.

== Brainstorming Results
As a result of the brainstorming session, the team arrived at three physical design concepts and two software design concepts. Any of the physical design concepts are able to work with any of the software concepts. The physical concepts were sketched by hand, while the digital concepts were drafted using software like Figma.  

== Physical Concepts
=== Smart Containers/Bins
#figure(
  image("Concept Sketches/smartbinsketch.jpeg"),
  caption: [Finalized sketch of smart bin concept.]
) <concept1>
==== Description
The concept shown in @concept1 is a design that will assess the inventory of items by weight. Ingredients will be placed into durable polycarbonate containers that have load cell sensors at the bottom instead of the feet. The force information from the load cells will be added together and translated into weight before being relayed to the microcontroller in the bottom of the bin. The microcontroller will relay the weight data to the back-end application. This design would utilize Commercial Off-The-Shelf Components (COTS), keeping costs low while still meeting user needs of accuracy, versatility, and connectivity. 

==== Advantages
- The design is simple to implement and use; just put ingredients inside the bin, and it will start reporting the weight.
- The simple nature of the bins allows for modularity and customization. Bins of any size can be made. The top lid can be customized to be a large moth or hole pattern for spices. 
- Any ingredient works with the bin, whether it is liquid, solid, or whole.
- The bins are self-contained and can be placed anywhere, making them versatile. They can even be placed in refrigerators and storage rooms without additional infrastructure. 

==== Faults 
- Since the bins will be in contact with foodstuffs, they will need to be cleaned. Washing the bins may be difficult with the electronics, and the bins cannot be made dishwasher safe. 
- Restaurants would need to buy bins in order to use the system, which could have a high cost.
- The battery for the electronics in the bins would need to be charged/replaced every so often, which is inconvenient and unreliable. 
- The bins would require a wireless network for communication, which may be difficult since commercial kitchens have a lot of metal walls and ceilings, which tend to interfere with radio frequency communication. 
- Ingredients will need to be transferred to bins before being inventoried. This will have to be repeated each time new ingredients arrive. 



=== Smart Pad
#figure(
  image("Concept Sketches/smartpadsketch.jpeg"),
  caption: [Finalized diagram of smart pad concept.]
) <concept2>
==== Description
As shown in @concept2, the Smart Pad concept would consist of an array of load cells and RFID readers hidden under a pliable silicone or TPU top layer. The array of sensors will detect the presence of and read the RFID tags that are placed on the bottom of food containers. Based on the detected location of the RFID tag, the input of nearby load cells will be processed to assess the weight of the container. The large design of the pad will accommodate multiple containers and be able to simultaneously detect their weight. The pad will receive power from a wall plug and can use a wired or wireless connection for communication. To enhance the versatility and flexibility, it will detect product outages not by absolute weight, but by relative weight to the starting weight; once the measured weight is below a certain percentage threshold, it will designate it as needing refill. This design meets user needs by being extremely versatile, convenient, and robust, and it can be easily retrofitted into existing kitchens. 

==== Advantages
- Stationary design allows for wall power and wired connectivity, which increases reliability.
- The pad can work with existing containers, as long as an RFID tag is put at the bottom. Therefore, ingredients don't need to be repackaged. 
- The rubber top is durable and grippy, boding well for messy restaurant environments.  
- Design is extremely convenient and requires no human intervention or service intervals after set up.
- Design can easily fit onto existing shelves at restaurants.

==== Faults
- An array of sensors and advanced electronics can drive the price up. Especially since it does not use many COTS parts. 
- Could be prone to damage from extremely heavy ingredients like bulk liquids being dropped onto it. 
- It may be hard to retrofit onto fridge shelves due to the wired power requirement.
- Due to the flexible nature of item placement, the weight readings will not be as accurate due to interference and overlap between items and their impression on the load cells/pads.
- All items will need to be RFID tagged and correlated before being placed into inventory. 
- The calculations for reading weight and detecting tags in real time have a significant energy computation cost. Especially due to the nature of the signal processing required to differentiate between items and computers, the weight is based on multiplexed inputs. This could result in higher energy costs and more expensive micro-controllers.
- Only works on shelves and flat surfaces. 

=== Modular Beam-Break
#figure(
  image("Concept Sketches/beambreaksketch.jpeg"),
  caption: [Finalized sketch of possible beam break sensor design.]
) <concept3>
==== Description
The design depicted in @concept3 is a vertical array of beam-break sensors. The vertical array will be able to determine the quantity of an ingredient by the height of the ingredient in the container, thereby assessing how full the container is. The design is modular and is attached to existing containers via adhesive pads on the modules. The height can be customized to match a variety of containers. Each sensor will be connected to a microcontroller that will calculate the fullness of the container and relay the information to the app. This design would meet user needs by being affordable, easy to implement, and enabling connectivity.
==== Advantages
- Simple design and cheap components will make it very affordable
- Can be retrofitted onto existing containers, keeping implementation easy and initial costs low. 
- All components are solid-state and therefore have very low failure probabilities and long service intervals, making it robust. 
==== Faults
- Adhesives can be unreliable, especially in messy kitchen environments, and therefore may fail, making the system unreliable. 
- Similar to the smart bins, this design will face many similar issues due to wireless connectivity, requiring batteries, and affecting the ability to wash containers.
- The system requires containers to be clear
- The method of measurement is less accurate than weight and may be made worse by ingredients like spices, which often leave residue on the walls that could interfere with measurement. 


== Software Concepts
=== Mobile App 
#figure(
  image("Concept Sketches/iphoneappconcept.png"),
  caption: [example SwiftUI based app design created with Figma.]
) <iphoneconcept>
==== Description
Shown in @iphoneconcept is a conceptual iOS version of a mobile app. All information from the hardware will be sent to a cloud service and then sent to the app on the user's phone. The app would allow for simple monitoring of stock/inventory on the dashboard and ingredients pages. The user will be able to add items from the "add item" button, which will use the NFC/RFID functionality on modern phones to read and program new tags/modules, depending on the concept. The settings tab will allow the user to set thresholds on what weight is considered empty and when to send notifications. The alerts tab will include all recent messages from both vendors and the system. The concept meets user needs by being easy to use, convenient, and bearing no cost since everything is externally hosted. 
==== Advantages
- Simple to use interface.
- Facilitates vendor communication.
- Streamlines the ordering process.
- Allows configuring devices.
==== Faults
- Can be complicated for certain users.
- Requires cooperation from vendors in order to use the full extent of features.
- Cannot be locally hosted, which opens up connectivity/privacy issues.
- It only works on phones/mobile devices; no desktop or cross-platform access.
- High development cost. 

=== Web App
#figure(
  image("Concept Sketches/Websiteconceptgooglesheets.png"),
  caption: [Web app dashboard design example made using Google Sheets.]
) <webappconcept>
==== Description
Depicted in @webappconcept is a potential design for a website-based application for inventory tracking. The concept would use a Google Sheets plugin developed with Google AppScript to receive information from the physical hardware. The data would be displayed for the user, and the user would be able to easily monitor usage trends and predict future usage. This meets user needs by integrating with the spreadsheets many restaurant owners already utilize and are familiar with, while adding connectivity and convenience. 
==== Advantages
- It integrates with existing spreadsheet systems.
- Easy to share raw data with suppliers and easy to communicate with vendors through auto-filled order forms.
- No learning curve.
- Cheap development.
- Cross-platform/device agnostic.
==== Faults
- Requires interaction with raw data and complicated spreadsheets.
- The mobile interface will be lackluster and limited in function.
- No two-way communication; device settings cannot be modified from the web app.
- Clunky interface.
- No instant push notifications without using separate text or email notifications.

= Concept Selection
== Down Selection
 To narrow down the physical concepts to just two, the advantages and faults determined by possible end-users discussed in the prior section were evaluated. The Modular Beam Break system was determined to compromise too much on reliability and convenience compared to the other concepts, which would reduce its ability to penetrate the market as other solutions already fill that market space, as determined in @compeitivematrix. Additionally, possible end users pointed out that the concept would be impractical due to the attachment mechanism using adhesives, which they lacked confidence in with the presence of extreme temperatures, fluids, and powders in kitchens. For these reasons, the Modular Beam Break concept was eliminated, leaving the Smart Pad and Smart Containers. Both were preferred in discussions with potential end-users due to their convenient and robust design along with high accuracy. 

Both software concepts were considered viable by both the team and potential end users, and thus both will continue to be assessed by the Pugh Scoring Matrix. 

== Pugh Scoring Matrix
In order to narrow down both the physical and software concepts to a final choice, a Pugh Scoring Matrix was used. The Pugh Scoring Matrix compares two concepts against a reference design, which is a POS system, as that is one of the most common systems in restaurants besides manual inventory @noauthor_us_nodate. All designs were assessed on their weighted ability to meet user needs. The weight of user needs was established in  @pairwisecomparison and used in the Pugh Scoring Matrix to adjust scoring to add value to user needs that should be prioritized. 
=== Physical Concept Comparison
#figure(
  image("pughchartphysical.svg"),
  caption: [Pugh Scoring Matrix assessing the Smart Bins and Smart Pad concepts based on user needs.],
  kind: table
) <pughhardware>
=== Software Concept Comparison
#figure(
  image("pughchartsoftware.svg"),
  caption: [Pugh Scoring Matrix assessing Mobile App and Web App concepts based on user needs.],
  kind: table
) <pughsoftware>

== Final Concept Selection
To determine the final concepts, both the results of the Pugh Scoring Matrix and anecdotal opinions from potential end-users were utilized to reach a decision. 
=== Final Physical Concept Selection
As highlighted in @pughhardware, the Smart Pad concept best meets user needs by a significant margin. While the Smart Bins concept is not far behind, it is very similar in scoring to the existing reference design (POS), which indicates it won't offer much new value to the market. 

Two potential end-users who were interviewed stated they preferred the Smart Pad concept due to its significant advantage in terms of convenience, the confidence they had in its robustness, and simple implementation. They both agreed that the tradeoffs in terms of a possibly more expensive system and lower accuracy compared to the Smart Bin system were acceptable when considering the unmatched convenience and simple connectivity. 

However, some changes were made to the design based on feedback from end-users. Most notably, a flexible rubber top surface can be problematic in a food environment, so a rigid segmented top surface made from water-repellent, food-safe material will be used. Also, due to the parallel creation of a web app, an onboard display is redundant and only adds to possible failure points without providing much functionality. Additionally, the concept was updated to use USB-OTG #footnote[USB On The Go], providing connectivity and power through one port, simplifying installation. 

Accounting for all this feedback from potential end users and the Pugh Scoring Matrix, the team selected the Smart Pad Concept as the final choice. 

#figure(
  image("Concept Sketches/Updatedsmartpadconcept.jpeg"),
  caption: [Updated smart pad concept with rigid surface and no display.]
)

=== Final Software Concept Selection
As shown in @pughsoftware, both concepts have a significant lead over the reference POS design, but the Web App concept has a clear advantage over the mobile App. The primary advantage stems from the Web App's easy implementation and integration with existing systems, since most restaurant managers already use some form of spreadsheets for inventory tracking.

When discussing the design with two potential end-users, opinions were mixed. Both unanimously agreed that both concepts had significant advantages to any system they have used before, and the affordability of both was incredibly attractive, but they were divided as to which concept they preferred. Both appreciated the simplicity of the Mobile App concept's interface and streamlined experience but noted that the Web App concept's enhanced data analysis could prove to be more useful. The end-users also liked the device configuration functionality through the mobile app and the convenience of push notifications, making the experience more akin to smart home devices than commercial devices. 

Based on potential end-user feedback and the Pugh Scoring Matrix, the team decided that the Web App would satisfy user needs the best and selected it as the final concept. While the Mobile App is attractive in concept, it lacks important functionality like data analysis. Furthermore, the Web App has practically no learning curve for existing restaurant owners and is a drop-in solution that requires no restructuring of systems as it integrates with existing spreadsheets. 

Based on additional research and discussions with end-users, the web app concept was updated to account for necessary back-end features and to add a mobile interface for the web app. 
#figure(
  image("Concept Sketches/webappbackenddiagram.png"),
  caption: [Architectural concept for web app made using Figma.]
)

#pagebreak()
#chapter("Grand Concept Design")
= Hardware
The physical component of the grand concept design is the smart pad. The smart pad will utilize an array of load cells and RFID modules to identify and weigh ingredients placed on the smart pad. Every item will have an RFID sticker that is bound to the ingredient through the software. Each segment and its associated RFID and load cell will be modular and independent of each other for easy assembly and expandability. All cells will aggregate their connections to the electrical box, which will house an RP2040 and digital multiplexers. These electronics will handle the inputs from all the load cells, the detections from all the RFID sensors and send data to the local network over WiFi or USB connection. USB will be used for power and optionally for data. All electronics will be coated in dielectric grease in case of spills. 

#figure(
  image("hardware arch.png"),
  caption: [Electronic architecture of concept design.]

)

The top surface will be made from polycarbonate for its strength and waterproof properties. The primary housing will be made from PETG#footnote[PolyEthylene Terephthalate Glycol] for its affordability and similar mechanical properties to polycarbonate. 

Each segment of the pad will be on the order of 5 square centimeters. The size of the pad will be expandable to a maximum that is dependent on the multiplexer's maximum capacity but will be on the order of 3x3 segments at minimum. The capacity of each segment will be 1kg static loads at maximum, but will be accurate to within 10g even with light (\~100g) loads. Each segment will connect to each other using magnets, a mechanical connection, and pogo pins. This will ensure the stability of the overall assembly and allow easy connection of modules without the user needing to deal with wires. 

#figure(
  image("Grand concept render.png"),
  caption: [Exploded rendering of the grand concept design module.]
)
#figure(
  image("GrandConceptRenderoverview.png"),
  caption: [Bird's eye view rendering of grand concept design with 9 segments.]
)

= Software
The software stack will consist of three primary components. The firmware for the microcontroller in the smart pad will interpret sensor inputs to determine the weight of each item. The database will store the weight information of each registered item. The progressive web app will present the data from the database in a readable format and allow adding new items to the database by registering new RFID tags for new ingredients. 

#figure(
  image("GrandConceptSoftware.png"),
  caption: [Grand concept software design made using Figma]
)


For containers placed on the pad that are larger than a single segment of the pad, the software will use an approximation algorithm similar to how black and white image processing works to identify the associated size of the container automatically and add the corresponding measurements together. 

The web app will have both a mobile and a desktop interface. It will integrate with a cloud database to ensure access to inventory monitoring even when away from the restaurant and enable the ability to send data to vendors for orders. The interface will list all ingredients and their inventory status, along with statistics about usage over time. 

= Usage
To use the system, the user will first set up the equipment. The only setup required is to plug the smart pad into a USB power source and connect it to a network (either through USB or WiFi). 

To start tracking inventory, the user must first attach an NFC sticker to the bottom of the container of the ingredient. They should then place it on the smart pad. After placing it on the smart pad, the system will detect the new NFC tag and populate the dashboard with a notification, allowing the user to set a name for the ingredient and category. 

Everything from this point onward is automatic. The system will use the initial weight measured at startup as the maximum weight and measure the relative weight of the item. This information will be displayed as a percentage on the web app. Each time the item is picked up and then placed back on the smart pad, its weight will be reassessed and reported to the database. If the item is refilled, no action is necessary to recalibrate the maximum weight. If ingredients with the same name are assigned to multiple unique NFC tags on multiple containers, the web app will automatically aggregate the readings into an overall measurement (not an average) to show the total stock of that particular ingredient. 

The web app will notify the user whenever an ingredient is low and show general usage trends. This data will also be accessible via a standardized database so potential end users may integrate the back-end with their current spreadsheets or wholesale order forms. 

= Anticipated Challenges
With this ambitious design, there are multiple potential challenges. One significant challenge the team anticipates is making the system robust. Kitchen environments often have liquid spills and fine food particles that can creep into crevices. Due to the smart pad having gaps between the rigid weighing sections, liquids and powder can easily seep in, so the mechanical components of the weight measurement system could be negatively affected or destroyed by foreign containments.  

Apart from durability, creating an intuitive interface that is easy for less technologically proficient users to pick up is another challenge that the team expects. Making an interface that balances both raw information and simplistic visuals will be difficult, especially since different restaurant managers may have different expectations of the system. This can be solved by making the interface modular and customizable. However, this adds complexity to the setup process and may be intimidating to less tech-savvy users. 

Scaling the system will be another significant challenge. To make the system effective for restaurants, there need to be enough smart pads for all the ingredients, which means the system needs to be able to grow to fit user needs. Reading information from so many sensors, along with aggregating and processing that data, can prove to be difficult, especially at the scale of medium to large restaurants. 

= Market Viability 
The proposed system provides numerous advantages over current market options in terms of convenience and accuracy. As discussed in @researchplantable, POS systems dominate the commercial market, followed by manual inventory. While POS systems are convenient, they lack accuracy, especially in more dynamic food preparation environments. POS systems serve fast food and similar restaurants well due to the quantized nature of their ingredients, but many cuisines do not share this nature. The proposed smart pad and companion software stack aims to solve this issue by providing hassle-free automatic inventory that is accurate for variably consumed ingredients. The team's proposed design is unmatched in versatility, convenience, and ease of use compared to any popular system on the market today. 

The target audience of such a product would primarily be smaller to medium-sized non-chain restaurants. Medium and small independently owned restaurants do not have the excess cash flow and extensive supplier relationships that chains and larger restaurants have and, therefore, cannot afford to overstock ingredients. The proposed system would eliminate any uncertainty about inventory for these businesses and allow them to focus on customer service and culinary excellence. While the upfront cost may be higher than manual inventory or other systems, the system will pay itself off in the long term due to the lack of subscriptions, commissions, and wages needing to be paid to take inventory by other means. 

Over time, the proposed design may break into larger restaurant and chain markets due to the ability for them to cut costs. This would be attractive to both investors and restaurant patrons as investors would have higher margins and patrons would have lower prices. 

Furthermore, the proposed system can be adopted by consumers for simple produce and pantry tracking as a convenient feature. The market is already crowded with grocery tracking apps and smart fridges with cameras to allow consumers to check how much produce they have at home. With the proposed system, consumers can have a simple way to check their pantry's stock with confidence. 

The minimal long-term cost combined with this unique feature set will propel the proposed product to become the new dominant method for inventory tracking across restaurants and homes.  


#pagebreak()
#chapter("Prototyping Design")
= Description of Prototype 
There are two main factors that will limit the fidelity and functionality of the prototype, those being the budget constraints and the physical size of the electronics. The budget of 120 dollars limits the scale of the prototype since the smart pad requires an array of RFID and load cell modules, which will add up quickly. This is exasperated by the fact that all modules and electronics need to be ordered in low quantity and be COTS components. The usage of COTS parts has the additional effect of reducing the fidelity of the prototype since the size of the electronic modules, their respective breakout boards, and wiring will be much larger than a system that uses custom PCBs with integrated circuits (IC). 

Apart from the physical smart pad prototype, the software prototype faces timing constraints and integration limitations. The development of the full software stack within such a constrained time period will be difficult since three separate components need to be built from scratch and linked together. Additionally, vendor integrations will be difficult to prototype since that would require interacting with real vendors' APIs and digital sales platforms, which is not feasible for the prototype. 

Given these constraints, the smart pad prototype will consist of four discrete segments for weight measurement and an attached electronics box. The segments will be discreet and self-contained but not necessarily modular. The electronics box will use a Raspberry Pi Zero 2 W along with analog-to-digital converters and multiplexers to handle the inputs from the four load cells and RFID modules. The smart pad segments will use 1kg load cells and will be on the order of 4x4 inches. The smart pad prototype will not support the ability to automatically detect the size and total weight of a container using multiple load cells due to the extremely limited resolution of a 2x2 segment pad. To ensure the stable and rigid construction of the casing, FDM 3D printed PETG parts will be used. 

#figure(
  image("prototypesketch.jpeg"),
  caption: [Smart pad concept prototype sketch.]
)

The software prototype will consist of simple weight and RFID reading software and will directly upload the correlated data to a simple cloud database. The front end will consist of a basic dynamic web app that will display the information from the database. 

#figure(
  image("PreliminaryWebappSketch.jpeg", width: 3.5in),
  caption: [Web app concept prototype sketch.]
)

To create the smart pad prototype, 3D printing will be used to create the casing and all non-electronic components. All electronics will be COTS parts. The wiring will be rudimentary, and all components will connect directly to the microcontroller instead of using a serial bus or area network. To make the final prototype, a smaller-scale smart pad consisting of just one segment will be made. 

= Prototype Design Requirements
The basic requirements of the completed prototype are as follows: 
+ Multiple weight-sensitive segments. 
+ The Weight-sensitive segments can reliably support ingredients.
+ Weight measurement is accurate and precise.
+ The Smart Pad is water and dust-resistant.
+ The Smart Pad has internet connectivity and communication. 
+ The web app is accessible on all platforms/devices.
+ Web app is responsive to user input and smart pad changes.

= Testing Methodology and Verification Plan
To validate the functionality of the prototype, a variety of tests will be conducted to assess whether the system meets each requirement laid out in the Verification Score Card.

#figure(
  table(
    columns: ((2in), auto, auto),
    table.header([*Design Requirement*],[*Methodology*], [*Trials*]),
    [Multiple weighing segments],[Count the number of independent weighing segments.],[1],
    [Segments reliably support ingredients],[A container weighing 500g will be placed on the pad for a duration of 10 minutes, and the change in weight measurement will be recorded. A container weighing 1kg will be placed on a pad for a duration of 10 sec, and the accuracy of a 500g container’s reading will be assessed.],[1], 
    [Accurate and Precise weighing],[A container filled with water will be placed on the pad. A known amount of water will be removed, and the accuracy of the relative weight measurement will be assessed.],[3],
    [Water & Dust resistant],[50ml of water will be spilled on the top of the pad. 1 tablespoon of salt will be poured on the pad.],[1],
    [Internet connectivity & communication],[The report rate will be measured using I2C toolkit on the raspberry pi microcontroller. The link speed will be measured using iperf on the raspberry pi.],[5],
    [Cross platform web app],[The web-app functionality and progressive web app functionality will be qualitatively assessed on 4 different devices. A Windows computer, Mac OS computer, iPhone, and android phone.],[1],
    [Responsive Web App],[The time it takes for the web app to update with new information after the state of the smart pad changes will be measured manually. An item will be placed or removed from the smart pad and a timer will start. The timer will stop once the web app updates accordingly],[3] 
  ),
  caption: [Testing methods for design verification.]
)


= Correlation Matrix and Verification Scorecard 
#figure(
  image("correlationmatrix1.png"),
  caption: [Correlation matrix between the design requirements and user needs.],
  kind: table
)
#figure(
  image("distribution.png"),
  caption: [Verification scorecard points distribution table.],
  kind: table
)
#figure(
  image("scorecard.png"),
  caption: [Verification scorecard and rubric.],
  kind: table
)
Based on the priorities highlighted by the correlation matrix, the functionality of the web app and the internet connectivity features are the most important aspects of the prototype. Furthermore, the verification scorecard demonstrates that features such as durability and accuracy can be compromised on as they are less of a differentiator of the prototype. 

= Prototype Preliminary Design and Mock-up 
To visualize the prototype, a rudimentary physical mockup made using cardboard and tape was constructed. This helped the team assess the proportions of the prototype and assess the general form factor of the final design. 

From the construction, the team learned that the electronics housing for the microcontroller should be in the back to provide clear access to the front. It would also be helpful to utilize a wedged shape to keep it out of the way of containers and add to the strength and spill protection. Additionally, the team learned that the modules for the prototype should be fairly large to accommodate the sizes of containers frequently used for ingredients in the food industry.

These discoveries helped the team decide the next steps and will influence the final design. Particularly, the final model will use a wedge-shaped housing, and the module size will be made larger to accommodate an entire container on its own, since multi-module measurements are not within the scope of the prototype.

#figure(
  image("CardboardMockup.jpeg"),
  caption: [Mock of smart pad design concept made using cardboard and masking tape.],
)

The above initial prototype highlighted the segmented and compounding nature of the intended design but would not have been replicable at a reasonable scale. Based on the basic mockup, a preliminary CAD design was drafted. It includes the load cell geometry but lacks detail on electronics and the inter-module connections. This CAD design utilizes more feasible dimensions and eliminates unnecessary segments from the smart pad.

#figure(
  image("draftcad.png"),
  caption: [Isometric view of prototype design CAD Assembly draft.]
)
#figure(
  image("draftcadcutaway.png"),
  caption: [CAD draft of load cell geometry within a weigh module.]
)

Based on the CAD drafts, the casing and top plate can both be 3D printed out of PETG which will simplify manufacturing and ensure the material is food-safe. The load cell and electronics will be consumer-grade COTS parts. 

#pagebreak()
#chapter("Detailed Design")
= Prototype Fabrication & Evolution 
== Smart Pad
To evaluate the team's initial design and find points for improvement, a preliminary prototype of the smart pad was made. This prototype only included one module and left the electronics unhoused for ease of access. This was accomplished by acquiring a 1kg strain gauge load cell, an HX711 ADC, and a PN532 NFC module. These electronics were connected to a Raspberry Pi 4B, and preliminary firmware to test their capabilities was written. The case design was also printed out of PLA, and the electronics were installed. 

#figure(
  image("preliminaryprotopic.jpeg"),
  caption: [Photograph of a single module of the preliminary design.]
)


The team then experimented with the prototype and decided on the following improvements:
- The microcontroller should be shrunk to a Raspberry Pi zero.
- The case should have a cover in between the pressure plate and base to protect electronics from spills and contaminants. 
- The walls can be made thinner, and the flat surfaces can have pocketing to reduce weight, material usage, and manufacturing time. 
- The corners should have a small fillet to improve the surface finish.
- The case should have holes for cable pass through.
- An external electronics box is unnecessary as the electronics can fit within the cases.

#figure(
  image("Revisedprotoassembly.png"),
  caption: [Revised prototype CAD assembly.]
)

Using the lessons learned from the initial prototype, the team redesigned the prototype to accommodate the previously discussed improvements. The most notable changes are as follows:
- The overall height was shrunk so that standard-length bolts can be used.
- The flat surface of the base and pressure place was pocketed with a parametrically designed pattern.  
- The walls of the case were shrunk to 1.2mm, which results in exactly 4 perimeters being printed. This maintains the structure but prevents any infill from being printed, saving time and material.  
- A flat top cover was integrated into the design and fastened using bolts.
- 2mm fillets were added to the corners.
- Hexagonal holes for cables to pass through were added.
- M3 bolt holes to attach modules to each other were added. 
- The gap between the case and pressure plate was increase by 6mm to provide more room for flex.
- All electrical joints were soldered to improve signal fidelity and reliability. 
#figure(
  image("Revisedprotocase.png"),
  caption: [Redesigned case CAD model with cover mounting holes, parametric pockets, and solid walls.]
)
 The four modules of the revised design were then printed in PETG and the corresponding electronics were installed in each one. A TCA9548A I#super("2")C Multiplexer was also added to handle the additional inputs in the prototype.  //include pic here

After all the electronics were installed, the firmware was rewritten to more reliably detect NFC tags and more accurately sense weight. Cloud functionality and wireless connectivity were also added to the firmware. 

The revised prototype was then put through the verification tests outlined in the verification scorecard. Since the firmware was not complete during the testing, the design scored a 21.5/25. //include pic here

Due to the pocketing and additional holes, the print time for each module was greatly reduced, but the overall rigidity was decreased and the reduced weight made the pad more prone to slipping. However, this compromise was worth it since the lower print time allowed for faster manufacturing and saved approximately 100g of filament per module. 

#figure(
  image("Wiringharness.jpeg"),
  caption: [Final prototype internals.]
)


== Web App
The back end of the web app was constructed first. Initially, a MongoDB database was made with a JSON structure accommodating the following fields:
+ Item ID - the NFC tag ID number 
+ Item name - a user-defined name for the item
+ Item quantity - the last measured relative weight of the item
+ Threshold - user-defined relative weight of the item for which an alert should be sent
The front end of the web app was then developed using Flutter. The web app uses a primary dashboard page that contains item cards for each registered item in the database. However, during the construction of the web app, it was determined that there are significant integration advantages if the database is migrated the Firebase. MongodDB was selected for its ease of use in the firmware, but the better front-end integration of Firebase was prioritized in this situation, so the back-end was moved to Firebase. 
#figure(
  image("Protowebappscreenshot.png"),
  caption: [Screenshot of debugging prototype web application.]
)

The web app was then evaluated using the methods outlined in the verification scorecard and met all device compatibility requirements. It was planned for the web app prototype to be deployed, but due to the time constraints, difficulty in acquiring a domain, and associated costs, the team decided against it. This did make verification more difficult as the target devices had to be put into development mode or a simulator had to be used, but none of the verification requirements called for the web app to be deployed, and all cloud functionality still worked.  


= Final Prototype Design
The final prototype design incorporates elements that aim to meet all the primary user needs identified by the in-depth project development research. The smart pad is convenient and easy to implement while retaining affordability by its scalable design. The web app provides an easy-to-use and responsive interface that helps users make informed decisions without the need for tedious manual labor. 
#figure(
  image("Finalprotopic.jpeg"),
  caption: [Final Smart Pad prototype.]
)

The final prototype design goes beyond currently available options since it combines convenience and accuracy, something no current system can do. It also integrates software in an elegant fashion, which is easy for anyone, not just spreadsheet wizards, to use. 

#figure(
  image("finalwebapp.png"),
  caption: [Final web app prototype.]
)

To make the design possible, multiple custom components were made. The web app is built on the Flutter and Firebase frameworks, but the interface is entirely custom. The electronics for the smart pad are all COTS, but use custom firmware. The smart pad's case and other physical components are entirely custom and consist of a case that holds the electronics, a cover to protect from spills, and a pressure plate for the items to be placed on.  

= Revised Grand Concept Design 
Due to how architecturally different the grand concept design is, many of the flaws identified through the prototyping process do not affect the grand concept design. However, there are still some small things observed during the construction of the prototype that would change the grand concept. 

First of all, it was noticed with the prototype that it tends to slip on smooth surfaces. Therefore, the grand concept should incorporate rubber feet to enhance stability and prevent slippage. However, this problem will be less prominent in the grand concept since the collective friction of the additional modules will assist in its inherent grip. 

Second of all, it was noticed that the power draw of the electronics in parallel adds up, and considering the usage of Raspberry Pi Picos in the grand concept design, a separate external power system, along with in-line power regulation modules, should be implemented in each module. This will prevent any potential power draw issues that could occur at the larger scale while maintaining the simple modular functionality. 


#pagebreak()
#chapter("Final Prototype Verification")
= Final Prototype Score Card
#figure(
  image("scorecard.png"),
  caption: [Filled out score card from the final prototype verification conducted under the supervision of an independent external party. ]
)
= Score Card Result Analysis
Based on the prototype's performance on the scorecard, the prototype was able to demonstrate sufficient functionality and act as a proof of concept. It is also important to note that the prototype passed with flying colors and exceeded in multiple categories. (Details can be found in Appendix E)

In our initial prototyping plan, we heavily emphasized a focus on connectivity and the software, and that is evident here as both the software and connectivity abilities passed with despite the intricate scoring requirements. 

All in all, the team succeeded in constructing sophisticated and functional prototypes that exceeded the initial prototyping plans. While this prototype does not truly meet the functionality of the Grand Concept design, it is a strong step in the right direction. 


#pagebreak()
#chapter("User Validation") 
= Goals
To determine the success of the prototype and market viability of the design concept, a user validation plan will be implemented. To do this, the most the ability of the prototype to meet the most significant user needs will be assessed. Based on the results of the pairwise comparison, the three most important user needs are as follows:
+ Easy to implement - Can be simply retrofitted into existing infrastructure without a significant overhaul. Easy for new users to learn. 
+ Convenient - Requires little human intervention and completes the majority of tasks autonomously and reliably. Should not require technical knowledge or expertise to use. 
+ Affordable - Low initial costs and little to no operating costs (including labor). Should be scalable to conform to user needs. 

The objective is to determine whether the design is capable of solving the issue of inventory management in restaurants. To do this, potential end users will be interviewed, and analytical comparisons to existing solutions will be conducted. 

For the interviews, at least two restaurant managers/owners who operate small to medium-sized non-chain restaurants will be presented with an in-depth description of the grand-concept along with the prototype, and interviewed on their opinions on the system, and whether or not they would implement it. 

In addition to the interviews, a comparative cost analysis using real data from at least two restaurants will be compared to a theoretical cost calculation of the grand concept. This will determine the economic viability of the design within the target audience. 

= Validation Methodology 
== Ease of implementation
Potential end users will be interviewed to validate the ease of implementation. In the interviews with restaurant managers/owners, the interviewee will be presented with a brochure describing the functionality and design of the grand concept along with the final prototype. They will then be asked whether or not they believe they could implement the system within a reasonable time frame that they would be comfortable with.

== Convenience 
Data from interviews will be used To asses the convenience of the system.
Interviewees will be asked whether or not their current system is convenient for them and whether they feel the grand concept presented to them would be more or less convenient. In addition to the interview with the restaurant managers/owners, a survey will be distributed to restaurant employees, which will present them with the grand concept and ask whether or not they would find the system more or less convenient than their current inventory management method.  

== Affordability
To determine the affordability of the system, the same restaurant managers/owners will be asked three questions. First, they will be asked for a breakdown of the current expenses related to inventory management (including labor), along with any initial costs they may have incurred. Second, they will be asked to request a quote from a  company that offers an inventory management solution (e.g. POS system or Tag tracking system providers). Third, the interviewee will be provided with the potential costs (both initial and expected upkeep) of the grand concept and be asked which solution is cheaper. The interviewee will not be asked to reveal the cost of the quote if they do not volunteer the information to protect the privacy of their business. 

= Ethics
Due to the personal nature of conducting interviews, it is important to respect the interviewees. Interviewees' identities and/or business identities will be obfuscated by the usage of pseudonyms. The survey conducted with restaurant employees will be anonymized to allow responders to answer without fear of judgment. 

= Interview Results
Two restaurant owners were interviewed on their thoughts on the Quantifi system and whether or not they would implement it. Both interviewees found the system to be intuitive and convenient. They remarked at the ease of use, but were concerned about the robustness of the system; while they were satisfied with the water resistance, they were more concerned about large impacts or slamming ingredients down. They also shared concerns about having to re-zero/calibrate the system every so often. Unfortunately, a cost analysis comparison could not be conducted due to the complexity of obtaining a quote and respect for the interviewees' time. They were impressed by the sophistication of the web app, but recommended adding hidden drop down fields with auxiliary information that is rarely used, but occasionally needed. Overall, the two interviewees found the system very attractive and expressed interest in beta testing a pre-market version more similar to the grand concept design. 

= Survey Results
A survey was distributed to 18 employees at multiple restaurants including employees who work at the restaurants owned by the two previous interviewees. They were asked "Based on the flyer and information about the Quantifi system, do you believe it will be more convenient for you  than the current system?". The flyer they were presented with can be found in Appendix B. 

#figure(
  image("Survey.png"),
  caption: [Results of restaurant employee survey.]
)
Based on the results, a super majority of employees belive that the Quantifi system would be more convenient than their current system. There is a large proportion of unsure users which is logical since the concept is novel and foreign to most respondents. However, the overall results indicate that the final grand concept design provides a strong proposition and potential end-users feel that it could enhance their workplace experience.  


#pagebreak()
#chapter("Value and Impact")
= Value Matrix
To assess the potential value the grand concept presents, a variety of stakeholders were identified, along with the potential impacts across multiple categories. 
#figure(
  image("ValueTable.svg"),
  caption: [Value table with stakeholders and predicted value categories.],
  kind: table
)
= Economic Impact
Since the concept design has both physical and software components, there is high potential for continuous and reliable revenue, even with a slow adoption rate. The primary costs for the design are the physical case, electronics, and software. The physical case is cheap to manufacture at medium to large scale, as it will be entirely injection molded PC and PETG. The electronics would utilize a custom PCB, but will still utilize COTS like an RP2040, keep costs low. The firmware will not need updating, so it will be cheap to maintain, but the web app will need continual updates and will incur costs for the cloud services. 

The startup costs will be relatively low since different manufacturing methods can be used before sufficient demand is reached. For example, injection molds have extremely high initial costs, so the case can be manufactured using 3D printing until sufficient revenue is achieved. The production of custom PCBs is also quite cost-effective, even on a small scale, by outsourcing manufacturing. The software costs will also be low at a small scale since web app hosting is largely free for small-scale and the database structure is incredibly efficient.

The revenue, however, will be multifaceted. There will be an initial cost for the smart pad modules, which can turn a small profit, and there will be continual revenue by charging a subscription for software/cloud services. This hardware + SaaS model is highly profitable with a quick return on investment. Furthermore, different subscription-oriented business models could be employed, but might have greater risk and are not as consumer-friendly. For example, many POS system providers lease the equipment and integrate the software expenses into the price. Others sell equipment at a loss but recoup revenue using subscription costs. 

Overall, even if the concept has a low initial adoption rate and struggles to break into the market, it can still be profitable. This is due to the low initial startup costs, low recurring costs, and profitable business model. The concept can undercut the competition while maintaining profit and delivering additional functionality. 

= Social Impact
The concept design has significant social and emotional impacts, largely afforded by the reduced food wastage. Regarding classical inventory, restaurants can either overstock ingredients or accept the risk of running out of ingredients every so often. Overstocking leads to the difficult decision of throwing away food that could have been consumed. Rampant overstocking also leads to higher demand and stress on vendors/producers, which can increase prices, resulting in negative socioeconomic impacts. Not overstocking runs the risk of running out of ingredients, which is bad for the restaurant staff as they cannot accommodate patrons, and the patrons will be unsatisfied. The concept design solves both issues by helping restaurants make informed purchasing decisions and eliminate the need for overstocking without running the risk of exhausting ingredients. 

Furthermore, there are numerous social benefits in terms of stress reduction. The concept design assists in improving the operational confidence of restaurant staff and managers since they know the content and status of their entire inventory at all times. Additionally, patrons will be happy to know that they are supporting a business that produces less food waste than others without the concept design. 

Overall, restaurant staff will have more time, less stress, and patrons will be more satisfied with the variety and consistency of availability afforded by the smart pad system. 



#pagebreak()
#chapter("Next Steps")
= Progression of Design
In order to bring the Quantifi system to market, the follow key steps will be made:
+ Refine the prototype software further and assess it using the final smart pad prototype in order to collect as much data as possible. 
+ Applying the lessons learned during the construction of the final prototype, redesign and manufacture the grand concept design at a very small scale. 
+ Design and manufacture custom PCBs for each module which house an RP2040 to read input from the load cell and NFC module. 
+ Partner with a potential end-user restaurant to deploy the grand concept prototype at small scale for pre-market testing.
+ Collect data and feedback from end-users.
+ Apply the insights gained from beta testing to construct a manufacturable market ready system. 
+ Deploy the system to restaurants and other potential end-users.
+ Collaborate with vendors to bring automated ordering integrations to the web-app. 

= Recommendations
To make this design a reality, the team will need the following:
- At least \$500 in seed money to continue R&D
- A \$2000 dollar investment to create the grand concept modules to be deployed
- Contact with food service industry vendors to create integrations. 
With this support, the team can turn the prototype into a full fledged profitable product. 



#pagebreak()
#chapter("References")
#bibliography("My Library.bib", style: "institute-of-electrical-and-electronics-engineers", title: none)

#pagebreak()
#show heading.where(offset:0): set heading(numbering: "A.1.i", offset: 1)
#chapter("Appendix A: Brainstorming Evidence")

#counter(heading).step()

= Gains Brainstorming (1/27/2025)
Task: Stocking spices in a kitchen
Additional Pains: Transferring bulk products to smaller containers for usage in the actual kitchen

Pain: Buying food when it's already in the kitchen
Gain: Less overall food waste/ potential for food waste

Pain: Running out of ingredients when they are needed
Gain: Increase overall customer satisfaction and reduce the chances of unsatisfied customers

Task: buying groceries to stock the kitchen \
Pain: purchasing excess materials by accident \
Gain: less food waste\

Task: taking inventory of kitchen materials\
Pain: time-consuming, human error\
Gain: less labor cost\

= Poor solutions to problems (2/10/2025):
- An alarm is set off when a product is low, although the specific product is not specified 
- Paper order forms are mailed to the supplier 
- The product breaks when stock is low.

= Concept Brainstorming (2/13/2025): 
== Initial Sketches
#figure(
  image("Concept Sketches/roughbinsketch.jpeg"),
  caption: [Concept idea for smart weigh bins and a partnering app that allows for 1-click ordering.]
)
#figure(
  image("Concept Sketches/roughtraysketch.jpeg"),
  caption: [Concept of an intelligent weighing pad that reads QR codes from shelf items to identify them and record their weight. Utilizes a phone app for monitoring.]
)
== Discussion Notes
- Design needs to have some way to determine the amount of an item automatically without human intervention
- weight is probably the most accurate and convenient way to do so
- beam break sensors or a visual monitoring system (using computer vision) could also work but accuracy is debatable
- designs need to have some sort of connectivity
- What form of connectivity?
  - wired is cumbersome and not practical for some designs. However, POE could simplify connectivity for designs that are stationary.
  - WiFi. 2.4 Ghz would be the cheapest and most practical due to power efficiency and module size. Also long range but has to deal with interference
  - Low Energy Bluetooth (BLE) is very power efficient. Would have limited bandwidth and range but still should be good enough.
  - Zigbee or other ultra low power hub based connectivity that smart home devices use? Should have enough bandwidth and very practical for smaller/battery powered designs.
- Should digital infrastructure be locally hosted or on the cloud?
  - local infrastructure has low cost
  - Cloud is easy 
  - Using containerized apps like Kubernetes could allow flexibility and choice
  - IOS app would require some cloud back-end because of how apple's push notifications work 
- App is relatively agnostic to physical design. App only takes in measurement data, the rest of the functionality is separate from the physical design. App should be conceptualized separately. 
- App should incorporate the ability to see live data from the physical design
- App should have some sort of order helper
 - something that helps with filling out order forms automatically
 - something that can communicate with online marketplace APIs (like how Costco has a back-end API)
 - maybe direct restaurant to vendor communication through app? however this would require the vendors to make an effort. 
- What can measure weight?
  - load cells (but what type?)
  - force sensitive resistors
- Design should try to use as many off the shelf parts to keep costs down and complexity low. Also helps with repairability. 
- what about hygiene?
  - Design needs to be easy to clean and cannot be breeding ground for bacteria
  - flexible rubber needed for the beam break and smart pad might be a problem. Is silicone food safe?
  - Designs need to be at least IP56 rated so spills and such are not a problem. 
- signal processing. How to convert readings from sensors into weight. Can it be done reliably? load cells are accurate but expensive.


#pagebreak()
#chapter("Appendix B: Research Methods")
#counter(heading).update(2)
= Interview with Restaurant/Bar Owner
== Methods
A person with a personal connection to a member of the team was interviewed for the purpose of identifying potential pains/gains experienced in daily tasks. The interviewee was informed in advance that the interview would be conducted as part of an assignment for an engineering class. 

== Biography
Name: Gershen \ 
Age: 34 \ 
Occupation: Restaurant/Bar Owner \ 
Location: western suburbs of Chicago \ 
Education: Bachelor of Arts in Political Science \ 

== Key Points
- Before owning his bar, he worked as a bartender through college
- Obtained the funding for the bar from parents and family. 
- Currently serves an average of 200 patrons a day, and up to 500 a day on weekends. 
- As owner, he is responsible for the acquisition of ingredients and equipment. 
  - Dreads the task of inventory, and doesn't like to delegate it as it has led to some miscommunications and wrong orders before. 
  - Finds the different ways that vendors receive orders to be confusing and difficult to work with.
  - has transitioned some produce tracking to using POS systems, but there are limited options, technology is not his strong suit, and it doesn't work well for certain types of ingredients like spices. 
- Keeping the kitchen clean is difficult
  - cross-contamination is a major danger and is hard to manage
  - cleaning knives is necessary but is dangerous to do properly

== Raw Notes
_"Q" are prompts from the interviewer, "A" are responses from the interviewee. Text besides direct quotes are approximations of what was said._\

*Q:* Tell me about yourself. 

*A:* 
- Bar/restaurant owner 
- lives in "western suburbs of Chicago"
- 34 years old
- west European 
- Degree in polisci from uchicago

*Q:* How did you get into owning a bar?

*A:* 
- Was a bartender in college
- enjoyed it a lot so opened his own near campus
- funding was largely from parents
- serves over 200 patrons a day on weekdays and up to 400 a day on Fridays/weekends

*Q:* What differences in responsibilities do you have by going from bartender to owner? 

*A:* 
- Has to focus much more on business
- mixed opinions on whether he likes it more or less
  - liked interacting with people and serving people
  - disliked the menial labor 
- not as different as one might expect
- also manages significant social media presence

*Q:* Can you elaborate on the aspects of working in the bar industry that you don't like?

*A:* 
- Stock management is a big issue
- Sanitation and cleaning is annoying
- people management is difficult
- It was hard to learn how to build a social media brand presence which is important for food service industry 

*Q:* Could you tell me more about the issues with sanitation please?

*A:* 
- Bars and kitchens get dirty especially with the volume of food and drinks they have to move in and out. 
- Made worse by the frantic rushing during peak hours 
- spills and accidents are common and need to be cleaned up quickly to avoid problems with contamination or more accidents like someone slipping 
- Cleaning utensils is tedious, not all utensils and such can be put into large dishwashers and human dishwashers are slow and wasteful 
- washing knives is a pain point due to the danger, not being able to put them in dishwashers, and the importance of their sanitation. 

*Q:* Could you describe some of the issues you have with stock management?

*A:* 
- keeping track of inventory is hard. Used to use manual inventory which was tedious and sometimes caused big issues due to human mistakes
- Recently transitioned to a POS system which was very expensive but worth it, however the POS system does not actually monitor inventory and only tracks usage. 
- usage tracking allows for inventory prediction but they still do inventory every few days manually. 
- Communicating orders to vendors is annoying due to different mediums, order forms, and marketplaces. 
- Certain ingredients like spices are extremely hard to inventory 
- does not like overstocking and does not have the excess cash flow to do so 
- running out of an ingredient can kill revenue quickly and make worse customer experience
  - bad for brand
- despite being young, technology is not a strong suit
  - POS interface is clunky and un-intuitive
  - data analysis is impossible since the raw data is hidden 
  - POS company requires a subscription for software

*Q:* Besides issues with running a bar, are there other issues you face in day to day life?

*A:* 
- Commuting during the winter is hard
- Has a carpal tunnel issue in his left hand 

*Q:* "Can you elaborate on your difficulties with commuting during the winter please?"

*A:*
- Road Salt is a big issue
  - cleaning it off is very tedious
  - understands it is necessary for safety but still hates it 
  - corrodes and damages exterior of his car
  - car already has scratches and rust damage despite being only a year old just because of the road salt
  - cleaning off the salt is near impossible because car washes don't work when its below freezing which it often is
  - scraping salt off can damage the exterior and is tedious
  - has tried some sprays and cloth before but again it was tedious 
- ice is another issue
  - ice is hard to scrape of windshield
  - ice is even harder to get off side mirrors since they aren't as scratch resistant as windshield and are recessed.
- Generally dislikes commuting
- no public transit since it is a suburb (at least not practical transit)


= Concept Review by Potential End Users
== Methods
Two small/medium restaurant owners were interviewed regarding their opinions on both the physical and software design concepts. The interviewees were provided with the finalized concepts as depicted in @concept1, @concept2, @concept3, @iphoneconcept, and @webappconcept, along with the associated descriptions. Interviewees were given time before the interview to examine the information provided. 

The interview was conducted simultaneously with both interviewees discussing their opinions with each other and the interviewer. Interviewees were allowed to respond with questions as documented below. 

== Raw Interview Notes
_"Q" are statements/prompts from the interviewer, "A1" are responses/questions from the first interviewee and "A2" are responses/questions from the second interviewee. Text besides direct quotes are approximations of what was said._\

*Q:* What are your thoughts on the Smart bin concept?

*A1:*
- likes the simplicity of the design
- likes how it can be used with liquids or powders just the same
- points out they can be used in refrigerators without changing anything

*A2:*
- Likes the "self contained no-fuss" design
- appreciates the modularity of the top lid 
- worries about the battery and charging
- points out that there could be durability issues with the load cells getting dirty and jammed
- Asks: "Will the electronics be sealed?"

*Q:* "Possibly, they will at minimum be splash and dust resistant, but likely not submersion resistant."

*A1:*
- might be problematic to clean the bins if they aren't water proof
- cleaning is important for a safe kitchen 

*Q:* What are your thoughts on the Smart Pad Concept? 

*A1:*
- likes the convenience
- interested in the detection mechanism
- worries that the mechanism for detection might not be accurate enough
- Asks: "How expensive are the RFID tags for the containers?"

*Q:* "They are RFID stickers and cost less than 10 cents per sticker in small quantities and even less in bulk."

*A2:*
- really likes how it's a "drop-in solution"
- likes the "innovative design"
- likes stationary design without batteries
- concerned about the design holding up to impacts when people dump/drop heavy produce on it
- Asks: "Will the RFID tags need to be replaced each time a new container arrives?"

*Q:* "They can either be replaced each time if they are stickers, or you can invest in different form of tags that can be reused but may be more expensive."

*Q:* "What are your thoughts on the Modular Beam Break?"

*A1:* 
- likes how it integrates with existing containers unlike the smart bins
- dislikes how the construction doesn't appear as streamlined

*A2:*
- is concerned about the accuracy of the sensors since containers can get dirty
- points out that it will require replacement of all opaque containers
- lack confidence in design and measurement method 

*Q:* "What are your thoughts on the Mobile App concept?"

*A1:* 
- Really likes the streamlined design
- likes how it can all be done from a phone and no need for computer
- likes how it allows for controlling devices directly.

*A2:*
- Also really likes the interface and "design language"
- feels that it might be constricting in terms of functionality 
- wants access to raw data for analysis and processing

*Q:* What are your thoughts on the Web App Concept?

*A1:* 
- likes how it looks exactly like their current systems
- likes how it can be locally hosted so no subscription costs
- likes the design, although not as much as the mobile app
- doesn't like not having 2 way communication with devices

*A2:*
- likes the utilitarian design
- likes the direct access to raw data
- loves the built in data analysis
- prefers utility over good looking/streamlined interface
- "We are business people, not just consumers, we can handle the real data"

= User Validation interviews
Two interviews were conducted with potential end users to asses the prototype and grand concept. They were presented with the following flyer describing the prototype along with the physical final prototype and spoken description of its functionality. 

#figure(
  image("Flyer.png"),
  caption: [Flyer the interviewees were presented with.]
)

== User Validation Interview raw notes
_"Q" are statements/prompts from the interviewer, "A1" are responses/questions from the first interviewee and "A2" are responses/questions from the second interviewee. Text besides direct quotes are approximations of what was said._\

*Q:* "Do you belive that you could implement the system in you restaurant without disrupting operations significantly and within a week?"

*A1:*
- Belives system could be implemented within one weekend barring technical difficulties. 
- Does belive minor disruptions due to produce misplacement could happen.

*A2:*
- Belives implementation would require the restaurant to be completely closed for one day and for all hands on deck to work on setting it up and transferring ingredients.
- Belives overall disruption would be acceptable if the system works flawlessly the next day. 

*Q*: "Do you belive the Quantifi system is convenient? Is it more or less convenient than your current system?"

*A1:*
- Thinks the system is very convenient
- Thinks it is more convenient than current system which uses a combination of manual inventory and a POS system. 

*A2:*
- Thinks that the system is convenient, although is concerned about longterm convenience considering having to rezero/recalibrate modules.
- Does not belive it will be more convenient than their current POS system.


#pagebreak()
#chapter("Appendix C: Prototype Working Drawing Packet")
#counter(heading).update(3)


#pagebreak()
#chapter("Appendix D: Software")
#counter(heading).update(4)
All software and files associated with the project are available in the GitHub repository below:\ 
\
#show link: underline
#text([#link("https://GitHub.com/AdityaGupta0/1182DesignProject")], size: 18pt)


#pagebreak()
#chapter("Appendix E: Additional Raw Data")
#counter(heading).update(5)
= Prototype Budget 
== COTS Parts 
#let sheet1 = csv("BudgetSheet1.csv")
#show table.cell: it => {
  if it.y == 0 {
    strong(it)
  } else {
    it
  }
}
#figure(
  table(
    columns: 5,
  ..sheet1.flatten()
  ),
  caption: [Prototype COTS component cost breakdown.]
)
A variety of COTS components were used in the making of the prototype. The final cost column in accounts for the part being already owned for which the price is halved. The price of externally purchased components add up to \$39.90 which is within the \$40 limit for external purchases. The total price of the COTS components is \$53.40.It should be noted that earlier iterations of the prototype used different components. For example, earlier prototypes used a Raspberry Pi 4B to speed up compilation time for faster code revision and testing. 

== Custom Parts
Apart from the electronics, the majority of mechanical components were custom manufactured through FDM 3D printing. The material used for the final prototype is Polymaker PETG, which retails for approximately \$20/kg. The cost of each component was determined by using the following formula:\
#set align(center)
$"(weight of part in grams)" dot ("$" 0.02)/(1 "gram")$
#set align(left)

#let sheet2 = csv("budget Sheet2.csv")
#figure(
  table(
    columns: 4,
  ..sheet2.flatten()
  ),
  caption: [Prototype Custom component cost breakdown.]
)
The total cost of the custom 3D printed components is \$14.92. The costs were calculated using the predicted filament usage in Prusa Slicer. 

== Total Final Prototype Cost
The total cost of the final prototype is \$68.32 when accounting for all custom and COTS components. This is far less than the \$120 maximum budget outlined by the requirements which demonstrates the cost effective nature of the smart pad design. The software incurred zero costs since all platforms and frameworks used were free and open source. 

= Notes from Final Prototype Verification
The following are analytical notes recorded during the testing of the final prototype in accordance with the score rubric outlined in the report. 
+ Smart pad is counted to have 4 independent segments. They are modular and reconfigurable.
+ A segment was able to support 1kg for over 10 minutes, exceeding the time duration required for just 500g.
+ A module was tested both with a water bottle (shifted from 444g to 267g) and an airpods case (shifted from 68g to 51g). In both situations, less than 1% error was observed for both absolute weight measurements and relative measurements. 
+ Smart Pad survived a water spill greater than 50ml and 1 tbsp salt. 
+ Using iperf, the latency measured was 71ms (>10hz) and the linkspeed was >3mbps through over 10 trials.
+ The web app functioned within emulators on chrome, firefox, safari, iOS, macOS, windows, android, and linux. 
+ The web app responded to changes in under \<1 second consistently without needing to refresh or interact with the web app. 


#pagebreak()
#chapter("Appendix F: Project Management Schedule and Meeting Minutes")
#counter(heading).update(6)
= Project Schedule
In order to meet deadlines and ensure the success of the team, a detailed plan for the construction of the prototype and conclusion of the design project has been made. The primary deliverables and tasks are as follows:
#set enum(numbering: "A)")
+ Start CAD modeling for prototype
+ Identify necessary electronics and quantity 
+ Finalize electronics selection 
+ Order electronics
+ Integrate electronics into CAD model
+ Test micro controller and sensor integration 
+ Write sensor input software for micro controller
+ Write internet connectivity software for micro controller
+ 3D print a single weighing module  
+ Test sensor integration with preliminary prototype
+ Build cloud database
+ Deploy cloud database
+ Finalize prototype design with necessary changes
+ Manufacture and assemble prototype
+ Finalize micro controller software
+ Create web app prototype in Figma
+ Build web app interface
+ Connect web app to database
+ Finalize prototype software and construction
+ Verify prototype using score rubric (FD1)
+ Create working drawings packet (FD3)
+ Create final pitch (FD2)
+ Finalize technical Design Review Document (FD4)
+ Complete Concept Development Review (R2)
+ Respond to grand concept pitch questions (P2)
+ User validation plan (DD2)
+ Communicating value and next steps (DD3)

== PERT Schedule
#figure(
  image("PERT chart.png"),
  caption: [PERT flow diagram. Purple tasks are the critical path. ]
)
As illustrated by the PERT flow diagram, numerous tasks can be completed in parallel. Most notably the deliverables related the the technical design review can be completed in parallel to the rest of the process as they do not integrate with the prototype construction. Additionally, certain aspects of the prototype can be completed in parallel, for example the software stack can start development before the completion of the physical smart pad prototype. However, there are some bottle necks that can prevent progression. For example, delays in shipping of electronics can bottle neck the progression of the sensor development pipeline and delay the completion of the physical prototype. While many other bottle necks are present, the highly parallel nature of the majority of the tasks lends itself well to the tight timeline the team faces. 

== Gantt Chart
#figure(
  image("Ganntchart.png"),
  caption: [Detailed Gantt Chart with timeline.]
)

= Prototyping Workday 1 Meeting Minutes
*Date:* 3/31/25 \
*Members present:* Aditya Gupta, Georgia Stone \
*Objective:* Establish this week’s goals for prototyping and what tasks will be completed. Finalize decisions related to the web app.\
*Accomplished:* 
- CAD for prototype is complete - [Aditya Gupta]
- Repository for web app is made and shared -[Aditya Gupta]
- Web app design prototype in Figma is complete -[Aditya Gupta]
- Electronics have been acquired and assembled -[Aditya Gupta]
- DD1 is on track for submission and is mostly complete -[Aditya Gupta]
*Tasks:*
- Test electronic sensors with micro controller -[Aditya Gupta]
- 3D print prototype components -[Georgia Stone]
- Begin building front-end of web app -[Adeel Khatri]
- Establish database -[Aditya Gupta]
- Finalize Gantt chart and submit DD1 -[Georgia Stone]
*Project Timeline:*
Based on the project timeline, we are one track, but we need to start testing sensor integration with the micro controller by 4/2/25 in order to meet our goals.\ 
*Decisions:* 
- To help with collaboration the web app prototype repository will be on GitHub so everyone can contribute. 
- Flutter and the Material UI kit will be used for the front-end of the web app. This will make the app widely compatible and make the functionality easy. 
- The back-end of the web-app will be made using mongoDB instead of Firebase. This is because mongoDB has better support for IOT devices and is easier to use. 

= Prototyping Workday 2 Meeting Minutes
*Date:* 4/10/25 \
*Members present:* Aditya Gupta, Georgia Stone, Adeel Khatri \
*Objective:* Discuss plans for user validation next week, final plans to complete, and showcase logistics. Implement results of user validation.\
*Accomplished:* 
- Smart pad prototype was built and completed. - [Aditya Gupta]
- Web app is built and functional. - [Aditya Gupta]
- Feed back from potential end-users was aquired - [Aditya Gupta]
*Tasks:*
- Polish software in both web app and firmware. namely, interface should include drop downs instead of static elements as learned from the user validation results. - [Aditya Gupta]
- Conduct survey of restaurant employees for user validation. - [Aditya Gupta]
- Making the flyer for showcase. - [All]
- Preparing for demonstration/final verification. - [All]
*Project Timeline:*
Based on the project timeline, we are actually a head of schedule as the database and web-app are already fully functional. We are a little behind on the smart pad prototype do to delays in printing. \ 
*Decisions:* 
- Last week's decision to use mongoDB was reversed in favor of firebase. This is because the firebase integration with flutter was more important than the flexibility of mongoDB 

#pagebreak()
= Prototyping Workday 3 Meeting Minutes
*Date:* 4/14/25 \
*Members present:* Aditya Gupta, Georgia Stone, Adeel Khatri \
*Objective:* Discuss plans to finish user validation surveys and process data. Discuss firmware issues and decide next steps. \
*Accomplished:* 
- All electrical connections have been soldered -[Aditya Gupta]
- All electrical components are coated in conformal coating -[Aditya Gupta]
- showcase flyer is finished -[Aditya Gupta, Adeel Khatri]
*Tasks:*
- Finish adapting firmware to the i2C multiplexer -[Aditya Gupta]
- polish the web app and squash bugs - [Aditya Gupta]
- Work on final pitch presentation - [All]
- Ask about dimensioning organic shapes for working drawings packet - [Aditya Gupta]
*Project Timeline:*
Based on the project timeline, we are on track to finish the final prototype and achieve full functionality by Thursday. The main task left is firmware for the smart pad and to polish the web app as much as possible before the showcase. \ 
*Decisions:* 
- Based on user feedback, the web app will reorder the buttons with the delete button having a confirmation and adding the ability to edit names after item creation
- User feedback also identified some bugs during testing, namely, items lingering after deletion and the ios/android versions not syncing with firebase.  
- Mass manufacturing has influenced the complexity of our design. Each module is extremely simple to make, and only consists of 6 parts total (including electronics). 

#pagebreak()
= Prototyping Workday 4 Meeting Minutes
*Date:* 4/15/25 \
*Members present:* Aditya Gupta, Georgia Stone, Adeel Khatri \
*Objective:*  Ensure the prototype is ready to present by Thursday, with most requirements being met. Also work on other final deliverables(drawing packet and presentation).\
*Accomplished:* 
- Web app polished and finalized - [Aditya Gupta]
- Final presentation slides started - [Aditya Gupta]
- Feedback on working drawings packet received and implemented. -[Aditya Gupta]
*Tasks:*
- Continue working on firmware for i2C multiplexer -[Aditya Gupta]
- Work on final pitch presentation and script - [All]
- Test the web app on device emulators to ensure cross platform functionality - [Aditya Gupta]
*Project Timeline:*
Based on the project timeline, we are on track to finish the final prototype and achieve full functionality by Thursday. The main task left is firmware for the smart pad and to polish the web app as much as possible before the showcase. \ 
*Decisions:* 
- Due to the potential hysteresis and time it takes to get a valid weight measurement, the smart pad should update the web app with inaccurate values and update them later with correct measurements to meet the time requirement. 
- The web app primarily needs to function on a browser, functioning as a mobile PWA is secondary in case something doesn't go right. 
- Based on instructor feedback, the TDR will be edited for linguistic consistency

#pagebreak()
#chapter("Appendix D: Team Working Agreement")
#counter(heading).update(7)

Term: Spring 2025 \
Created: 1/13/2025\
Last Updated: 2/17/2025\

= Team Information
Course Section: 8076 \
Team Designation: F \
Instructor: Dr. Bailey Braaten \
GTA: Sherri Youseff \

Contact information:
#table(
  columns: 3,
  [*Name*],[*Email Address*],[*Phone Number*],
  [Aditya Gupta],[Gupta.1516\@buckeyemailosu.edu)],[630-401-7653],
  [Adeel Khatri],[Khatri.94\@buckeyemail.osu.edu],[419-819-1781],
  [Georgia Stone],[Stone.1087\@buckeyemail.osu.edu],[304-917-1802]
)

= Team Values & Goals
What are the team’s top 5 values?
+ Open mindedness
+ Hardwork/perseverance
+ Creativity
+ Learning 
+ Collaboration

#underline[What are the team’s expectations of quality level? Top goals? Minimum acceptable goals? Include at least 1 goal regarding psychological safety, belonging, and inclusion.]\
- Quality should be the best possible work that members are practically able to produce
- Members should attempt to go above and beyond, even if not requested to do so
- Members should be respectful of each other and their identities, and accommodate each other 

= Communication and Meetings
#underline[What are your team’s preferred method(s) of contact and expected response time(s)?] \
We will communicate via iMessage group chat or email, but preferably group chat to ensure fast response times. We expect to respond within the day to each other (assuming it is not very late in the day).

#underline[How often do you plan on meeting to achieve your goals? (Do you anticipate this changing throughout the semester?)]\
We plan to meet at least once a week outside of class. We anticipate this increase during the design phase of the project due to increased workload. We will amend our agreement accordingly once the semester is in full swing and we have more clarity on the work needing to be completed. 

#underline[Primary and Secondary Meeting Day/Time/Location]\
Primary meeting days are Wednesday at 4:30pm on the first-floor lounge of Drackett tower. 
The secondary meeting time is Tuesday at 4:30.
Secondary meeting location is group study rooms in 18th Avenue library or online (only if an in-person meeting is impractical)

#underline[Individual(s) in charge of agendas, reminders, minutes]\
Adeel will be responsible in planning what will be done at meetings (Agenda and such).
Georgia will be responsible for meeting minutes.
Adi will be responsible for reminders and keeping track of submissions.
Roles will be swapped through the semester and will be amended in the agreement as necessary. 

= General Expectations and Group Norms
#underline[How are team members expected to behave? What are the group norms?]\ 
Group members are expected to treat each other with respect and to keep open minds. 

#underline[What are acceptable/unacceptable types of interaction?]\
Being rude, calling out someone in a hostile manner, blaming others, or not taking responsibility for actions are unacceptable. Being critical but constructive of work, collaboration and sharing ideas is expected and acceptable. 

#underline[What are team member expectations regarding attendance?]\
Team members are expected to attend every class/lab unless extenuating circumstances or other good reasons. Team members are expected to notify the rest of the group if they are unable to make a class, lab or team meeting. 

#underline[How are team members expected to behave during lab/class periods?]\
Team members are expected to be attentive and collaborative during lab and class periods.

#underline[What are team members meant to do between classes? Lab/class preparation?]\
Team members are expected to work on their assigned parts of group assignments and come to labs/class prepared. They should complete all necessary pre-class material for every class and strive to go above and beyond without encroaching on other’s tasks.

#underline[How are team members meant to ensure the team stays on track?]\
Team members will be accountable on meeting deadlines, not only for their own work but for others’. If they see someone is falling behind, they should check in with them and help them get on track if necessary. Members should communicate their status on assignments, so everyone is on the same page.

#underline[How are documents expected to be shared? (e.g. OneDrive, Google Docs, etc.)]\
We have a shared folder on OneDrive where everything will live, including presentations, files, and documents. The TDR and other reports will be done in Typst.

#underline[How many days before an assignment is due should everybody have their portion completed for review?]\
Everyone should have their portion done at least a day before the assignment is due so that every member has time to review each other’s portions and check for mistakes or possible improvements. 

#underline[When should team members first notify the group if they are struggling?]\
Group members should notify the entire group if they are struggling. They should use either an in person meeting or via group chat. They should notify group members as soon as possible, even if they don't necessarily need assistance immediately and want to try to figure out things on their own. 

= Individual Team Member Responsibilities
#underline[When/how will individual tasks/responsibilities be assigned?]\
Individual tasks/responsibilities will be assigned at group meetings or in class/Lab. For urgent task assignments, the group chat may be used as an alternative.

#underline[How will the team ensure work is fairly divided and that everyone participates equally?]\
Work will be divided in a way that suits everyone's strengths but is fair and even. The time everyone spends on their work should be roughly equal. We will ensure people are participating equally by holding each other accountable.
Are there specific roles that all team members have?
We do not have any specific roles besides who will do the agenda and meeting logistics yet since the nature of assignments is still unclear.

#underline[What specific tasks are team members in charge of?]\
Adeel will be responsible for coding and drafting assignments. Georgia will be responsible for team organization. Aditya will be responsible for digital asset management.  

#underline[How often will these roles/task rotate?]\
Once tasks are assigned, they will rotate every 2 weeks, but is up for discussion when the time comes. 

= Conflict Resolution
#underline[When there is disagreement amongst members, how will the team make decisions?]
Once the team goals, general member expectations, and individual team member responsibilities have been established, candid, non-threatening discussion must be held when the group or individuals are not meeting the agreed upon terms.

#underline[How will team members above be held accountable (be specific!)?]\
The team members will be held accountable by other members checking that they are on task and making progress. If someone is falling behind, another group member will discuss with them to make sure they are back on task. We will give each other constructive (but not hostile) feedback so we will all grow.

#underline[How will team members that are not meeting expectations (not contributing to the team effectively) be Addressed?]\
We will address these issues during a meeting and will discuss as a group possible strategy to amend the issue, such as lowering the workload given, discussing how they can contribute in other ways, or giving them the assistance they need to complete their work. 

#underline[How will team members that are not interacting appropriately with team members be addressed?]\
Team members not interacting properly will be discussed at a team meeting until a consensus on the next steps can be reached. 

#underline[How will the team handle resolving issues when a team member is not acting inclusively?
Team members not acting inclusively will first be addressed at team meetings and may be followed up by communicating with the instructor or GTA if problems persist. 
What are the consequences for violating this agreement (be creative!)?]\
Consequences include not being assigned certain responsibilities which are crucial to the group, not having a choice on their individual assignment, and/or communication with instructor or GTA about the specific issue. 

#underline[When is it okay to redefine goals, expectations, and responsibilities?]\
Whenever there seems to be ambiguity in expectations, the goals may be redefined, and the agreement may be mended. 

#underline[When will UTAs, GTAs, or the instructor become involved?]\
If there are persistent issues with a group member that wasn’t handled internally or is egregious, the instructors or GTA will be informed and requested to assist in mediation and remedies. 

= Expectations of Faculty and GTAs
If a team member fails to live up to this agreement even after intervention by the group, the situation may be reported to the staff, but the team will still be responsible for submitting a completed assignment. Staff will be available to meet with teams to resolve issues and mediate meetings when necessary.

= Team Signatures
#image("Signatures/Picture1.jpg", width: 200pt)
#image("Signatures/Picture2.jpg", width: 200pt)
#image("Signatures/Screenshot 2025-02-17 121601.png", width: 200pt)



  
