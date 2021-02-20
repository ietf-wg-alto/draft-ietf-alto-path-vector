Chair review from beginning of document to the end of S6.6. Part 1 of 2.

Major:
- S4.1, below Figure 2: Note that we do not have "availbw" defined in ALTO as a
  current cost metric, so it is not a good idea to use it here without
  qualifying it further. If used as is, it creates confusion. My advice would be
  to either qualify the use of "availbw" as a hypothetical cost metric, or
  choose an actual cost metric from the performance-metric draft and restate the
  example.

  Thanks for the comments. We make it clear in the new text that the metric is
  hypothetical.

  OLD:
   The single-node ALTO topology abstraction of the network is shown in
   Figure 2.

  NEW:
   The single-node ALTO topology abstraction of the network is shown in
   Figure 2.  Assume the cost map returns a hypothetical cost type
   representing the available bandwidth between a source and a
   destination.

- S4.1, "Case 1": I don't see how the "application will obtain 150 Mbps at
  most." Consider that the bottleneck bandwidth is 100 Mbps, as that is the
  bandwidth of the most constrained link. Once traffic leaves sw5, it can get no
  more than 100 Mbps on the remaining links. So, I don't understand how the
  "application will obtain 150 Mbps at most."? Perhaps I am missing something?

  We agree the computation process should be better explained. More details are
  now provided to explain 1) what is the objective of the application and 2) how
  it computes the value.

- S4.2.3: This paragraph, especially the second sentence onwards needs to be
  re-written to better flesh out the need. Currently it says, "While both
  approaches...", however, it is not clear that there are two approaches being
  delineated from each other here. It needs more edits so it reads better. (Some
  nits in this paragraph appear in the Nits section trying to tease out the
  language.)

  We agree the second approach is not clearly specified. The new text follows
  the same structure of previous paragraphs and only focuses on what is
  achievable with the PV extension.

  NEW:
   With the extension defined in this document, an ALTO server can
   selectively reveal the CDNs and service edges that reside along the
   paths between different end hosts, together with their properties
   such as capabilities (e.g., storage, GPU) and available Service Level
   Agreement (SLA) plans.  Thus, an ALTO client may leverage the
   information to better conduct CDN request routing or offload
   functionalities from the user equipment to the service edge, with
   considerations on different resource constraints.

- S5.1.3: When Section 5 begins, it says that "This section gives a
  non-normative overview of the Path Vector extension." However, in S5.1.3,
  there is a normative "MUST". (Same problem in S5.3, there are many "MUST"s
  there, and in Section 5.3.3 there are "RECOMMENDED" and "SHOULD NOT".)

  Generally, I am a bit hesitant that certain subsections of Section 5 ---
  Section 5.3.2 in particular --- appear to contain normative behaviour, and
  this should be specified in a normative section, or do NOT start Section 5 by
  saying that this section gives a non-normative overview, and make this a
  normative section. I understand this is a major comment, so please think how
  you want to handle this carefully.

  We agree the normative behaviors should be moved to specification sections.
  In particular, the normative contents of 5.3.2 are moved to 7.1.6/7.2.6 and
  7.3. And the normative contents of 5.3.3 are moved to 7.1.6/7.2.6.

- S5.3.2: Not sure I follow the logic in the first paragraph. As Fig. 4 showed,
  there is one PV request, and if ALTO SSE extension is being used, presumably,
  it will contain the "client-id". If the response contains a Path Vector
  resource, shouldn't that "client-id" simply apply to it? I am sure I am
  missing something here as you have thought about this more than me; perhaps
  you could add a simple example to make the problem more explicit.

  The idea is to allow SSE to push the updates for only one part in a PV
  response. However, we realize that the content of S5.3.2 is repetitive as RFC
  8895 (SSE) has already specified how to push updates for multipart resources.
  We now follow the design of RFC 8895 and there is no backward compatibility
  issue between PV and SSE now.

- S6.4: Why have a mini Security Considerations paragraphs in the subsections of
  S6.4, but not in the subsections of S6.3 and S6.5? I am not saying that you
  remove the mini Security Considerations paragraphs, but if there are security
  considerations worth pointing out in S6.4, I suspect that there are security
  considerations worth pointing out in S6.3 and S6.5? (One such security
  consideration is listed below in S6.5.1.)

  The reason of having mini security consideration paragraphs in Section 6.4 is
  because the document defines two properties in Section 6.4 and the Unified
  Property document asks for security consideration when defining a new
  property. However, for cost type definition, such a paragraph is not formally
  required so we do not include one.

- S6.4.2: "The persistent entity ID property is the entity identifier of the
  persistent ANE which an ephemeral ANE presents (See Section 5.1.2 for
  details)." ==> I am not sure what this means? Why is an ephemeral ANE
  presenting a persistent entity identifier? Is it important that you are
  defining an ephemeral ANE and associating it with persistent entities? If so,
  then please make this clear as there is a lot of ambiguity in this section.

  This sentence is based on the contents of Section 5.1.2, which provides more
  details on ephemeral ANE and persistent ANE. We add an example to 5.1.2 to
  illustrate the importance of having persistent ANEs.

- S6.5.1: What is the effect if the ALTO server chooses to obfuscate the path
  vector, causing the client to experience sub-optimal routing. The client does
  not know that the server has obfuscated the path vector, so it MUST interpret
  the path vector as given to it by the ALTO server. This raises the question
  whether such obfuscation, because it is indistinguishable from a
  non-obfuscated response, creates an attack on the client? (Would a mini
  Security Consideration paragraph be appropriate here?) Clearly, since ALTO
  assumes that the server is trusted to some degree, the issue becomes (a) can
  the client, by repeated querying, figure out that it is being duped on
  occasion? (b) what does it then do?

  It is true that obfuscation may not guarantee that the clients can achieve
  optimal application-layer routing. However, it may have

Minor:

- S1, paragraph 3: Why would "job completion time" be shared by bottleneck
  network links? On first glance, job completion time is a function of the
  compute resources on the host not network links, but on further reflection,
  job completion time could also be a function of the network links on the host
  if the data needs to be marshalled to the job (process) in order for it to
  complete. If so, then perhaps reword as:

 OLD: For example, job completion time, which is an important QoE metric for a
 large-scale data analytics application, is impacted by shared bottleneck links
 inside the carrier network.

 NEW: For example, job completion time, which is an important QoE metric for a
 large-scale data analytics application, is impacted by shared bottleneck links
 inside the carrier network as link capacity may impact the rate of data
 input/output to the job.

 Thanks for the comment, we adopt the new text in the revised document.

- S5.1.1: "Thus they must follow the mechanisms specified in the
  [i-D.ietf-alto-unified-props-new]." ==> Here, it may help to point to a
  specific section of the I-D you want the implementer to follow the mechanisms
  of. Do you mean the naming mechanism defined in the I-D? The inheritance
  mechanism defined in the I-D?

  Thanks for the comment. We have marked the specific sections of the unified
  property for ANE (Section 5.1, Entity Domain) and the properties (Section 5.2,
  Entity Property).

- S5.1.2: How does the client know that an ANE in a response is ephemeral versus
  persistent? You answer this question in Section 6.4.2, perhaps you can put a
  forward reference to Section 6.4.2 as I am sure other readers will have the
  same question.

  Thanks for the comment. We add a forwarding reference and point the readers to
  Section 6.2.4 and 6.4.2, which both give more concrete examples of how to
  differentiate ephemeral and persistent ANEs.

- S6.2.4: "...their entity domain names MUST be ".ane"..." ==> MUST be .ane or
  MUST use the .ane prefix? I can't tell. Please specify this better through an
  example as well. You do have an example in the last paragraph, but the writing
  of the example is ambiguous. My understanding is: ".ane:NET1" is an ephemeral
  ANE, while "dc-props.ane:DC1" is a persistent ANE. Is that correct? If so,
  just explicitly mention this.

  Thanks for the comment. The entity domain name must be .ane (i.e., the first case).

  Your understanding is correct and we explicitly mention it in the new texts.

Nits:

  The comments below are adopted as they are unless specifically explained.

- S4.1: s/the scheduling. However,/the scheduling, however,/

- S1, paragraph 3: s/applications, however, the/applications, the/

- S1, paragraph 5: s/in a huge volume/in an increase in volume/

- S1: s/The pressure on the/The requirements on the/

- S1: s/ALTO server convey/ALTO server to convey/

- S1: s/that each identifies/that identifies/ or s/that each identifies/, each
  element of which identifies/

- S3: s/in a cost map or for a/in a cost map, or for a/

- S4.2.1: s/Gigabytes, Terabytes, and even Petabytes/gigabytes, terabytes, and
even petabytes/ (Reason: there is no need to gratuitously capitalize these.)

- S4.2.1: s/related to the completion time of the slowest data transfer./related
  to the data transfer time over the slowest link./

  The proposed change has a different meaning and we propose to use the following:
  s/which is related to the completion time of the slowest data transfer/which
  is related to the completion time of all the data transfers belonging to the
  job

- S4.2.1: s/the Path Vector extension/the extension defined in this document/
(This is repeated in S4.2.2 and perhaps elsewhere, please consider it as a
request for global change.)

- S4.2.2: s/It is getting important/It is important/

- S4.2.3: s/may have to make/will need/

- S4.2.3: s/and potentially with/and potentially need/

- S5.2: s/, meaning the/, this means that the/

Thanks,

- vijay
Dear Authors: This part concludes my chair review of path-vector, an important
ALTO extension. Thank you for your work on this document. I hope the comments in
this part and the first part help position the document better.

Chair review from Section 7 to the end of the document. Part 2 of 2.

Global comment: Please turn all "Content-Length: [TBD]" into "Content-Length:
XXX", where "XXX" is the computed content length.

TODO

Major:

- S7.1.3: When you first get into JSON object declarations, you should point the
reader to S8.2 of RFC7285, where the semantics related to the syntax used to
declare ALTO JSON objects is defined. This will help new implementers who pick
up this manuscript and need to understand where the declaration syntax, and
previously declared JSON ALTO objects, like ReqFilteredCostMap, reside.

  Thanks for the comment. We add a notations subsection in Section 7 and point
  to S8.2 of RFC 7285. References to the previous defined JSON objects are also
  added to the new text.

- S8.3: I think the ALTO response deserves a longer explanation here. Let me see
  if I understand correctly: the cost map returns two properties: NET1 and AGGR.
  On NET1, the max reservable bandwidth is 50 Gb (or GB?), i.e., inside the NET1
  abstraction of Figure 5, the max reservable bandwidth is much higher than the
  link bandwidth. For the AGGR (BTW, what does AGGR stand for? Minimum aggregate
  bandwidth?), the max reservable bandwidth is 10 Gbps, which is the bandwidth
  of L1. Yes? Please expand the explanation in the document to be as explicit as
  you can.

  Further, my suggestion would be to show the NET1 and AGGR from source 2.3.4.5
  to destination 4.5.6.1, because that will necessarily include traversing two
  links, L1 and L2. What would be the AGGR there?

  The current example is actually the result after obfuscation where the AGGR
  encapsulates the subnetwork NET1 and the connectivity between NET1 and NET3.
  We now give two response examples in 8.3. The first example gives the "raw"
  response and the second example is an obfuscated response.

- S9.2: I am not sure what the prescription here is. Whatever it is, it needs to
  be (a) explicit, and (b) stronger. Current text says that this document does
  not "specify" the use of path vector cost type with RFC 8189. Why does it not
  specify this? Is it because such integration is not possible? In which case,
  the document should say so. Or is it because the authors have not studied
  whether such integration makes sense and can be supported in a backward
  compatible manner? If so, well, say so. Or is it because such integration is
  not possible at all? If so, say so. This is a protocol document, we need to be
  as unambiguous as possible. (S9.3 is a good example of drawing a line in the
  sand.)

  We have rewritten the subsection to clarify the compatibility issue with the
  multi-cost extension. In particular, we explain why these two extensions
  cannot be used together.

- S10.2: Not sure why the MAY is normative here. This paragraph should be
  re-written in its entirety; it reads more like a draft set of notes than
  something well thought out.

  Thanks for the comment. We revise the subsection to include more discussions
  on the topic and propose potential directions.

- S11, last paragraph: I am not sure what "intolerable increment of the
  server-side storage" means here. Isn't the issue more along the lines of
  spending CPU cycles doing path computation rather than storage requirements?
  Conflating "storage" here does not seem to be warranted, but perhaps I am
  mistaken. Please advise.

Further, the text says, "To avoid this risk, authenticity and authorization of
this ALTO service may need to be better protected." ==> I am unsure how this
helps. The ALTO server has no means to authenticate the client, nor does it have
any means to know whether the client is authorized to send it a request.
Consequently, the best it can do to protect itself is to monitor client
behaviour and stop accepting requests if the client misbehaves (sends same
requests frequently, sends requests with small deltas frequently, or it can ask
the client to solve some puzzle before submitting a request, etc.). But
generally, this class of resource exhaustion attacks are hard to defend against,
and I am not sure that we will come up with something that is definitely
prescriptive here. But we should structure the discussion such that it appears
that we have thought of the issues here.

  Thanks for the comment. We have revised the paragraph.

Minor:

- S7.1.6, bullet item "The Unified Property Map part MUST also include
  "Resource-Id" and "Content-Type" in its header." ==> Doesn't the unified-props
  I-D already mandate this? If so, why repeat it here?

  No, this is not specified in the UP I-D.

- S9: I would suggest changing the title to "Compatibility with other ALTO
  extensions"

- S10.1, paragraph 3: I would suggest the following re-write for this paragraph:

"In practice, developing a bespoke language for general-purpose boolean tests
can be a complex undertaking, and it is conceivable that there are some existing
implementations already (the authors have not done an exhaustive search to
determine whether there are such implementations). One avenue to develop such a
language may be to explore extending current query languages like XQuery or
JSONiq and integrating these with ALTO."

(Please provide references for XQuery and JSONiq.)

Nits:

- S8.1: s/The example ALTO server provides/Assume that an ALTO server provides/

- S9.1: s/conducting any incompatibility./incurring any incompatibility
  problems./

- S11: s/requires additional considerations/requires additional scrutiny/

-S11: s/authenticity and authorization/authentication and authorization/

Thank you!
