/* Technical comments */

.- Section III Terminology – Path Vector bullet. Please, rephrase the
description, it is hard to understand, especially the second sentence. Not
clear. DONE

.- Section 4.2 – it refers to recent use cases, but it is not relevant how
recent are the use cases (in fact, for this, see my next comment). So I would
suggest to remove any reference to recent either in the title or the text.
Simply refer to use cases. DONE

.- Section 4.2 – there is a reference to an expired I-D which last from 2013 (so
pretty old). I would suggest to remove such a reference since somehow the
potential use cases it refers should be present here. DONE

.- Section 5.1.3, 2nd paragraph – “… and the response must return and only
return the selected properties …” – two comments here: (1) must should be MUST
in this context?; (2) “… and only return …” – probably redundant, better either
remove or rephrase as “MUST/must only return”. DONE

.- Figure 4 – the figure shows two response messages, but some questions arise
in this respect: (1) what happens if second response is not received?; (2) what
happens if only the second response is received? Is it silently discarded?; (3)
is there some expected timer for accounting time-out in the responses? It is
mentioned in bullet 2 that there could be some processing among messages, so it
can be assumed that some maximum delay could happen between both responses. DONE

.- Section 6.2.4, last paragraph - Hard to understand, not clear. Please,
rephrase/review. DONE

.- Section 6.4.2, Intended semantics text – it is not clear the association of
persistent to ephemeral. Why is this? What is the purpose? DONE

.- Section 6.4.2, last paragraph – The value of ephemeral is provided, but what
would be the value of persistent one? DONE

.- Section 9.3, 1st and past paragraph – they seem inconsistent since in one
hand the first claims incompatibility while the second claims compatibility.
Please, review them. DONE

.- Section 9.4 – When used with the calendar extension, should the ANE be always
persistent? I mean, same ANE for all the time views, otherwise could not
properly work. Please, clarify. DONE



/* Editorial comments */

.- Section I Introduction, pag. 5, penultimate paragraph – “… Path Vector
response involve two ALTO …” -> “… Path Vector response involves two ALTO …” DONE

.- Section I Introduction, pag. 5, last paragraph – “… the rest of the document
are organized …” -> “… the rest of the document is organized …” DONE

.- Section III Terminology stands that the document extends the terminology used
in RFC 7285 and in Unified Properties draft. This implies some precedence in the
edition of the documents as RFCs, if they finally progress to that stage. So I
would recommend to add a note for RFC Editor mention that precedence (note to be
remove once the document becomes a RFC). DONE

.- Section 5.1 – the text (2nd paragraph) auto-refers to section 5.1. Redundant,
better to remove. DONE

.- Section 5.2 – 1st paragraph – correct -> correctly DONE

.- Section 5.3, last sentence before Figure 4 – “… the ANEs in a single response
…” -> “… the ANEs in an additional response …” DONE

.- Section 6.6 – The second paragraph starts with NOTE; probably better to
rephrase writing it as a normal paragraph. DONE

.- Section 9.2, last sentence – “compatible” -> “compatibility” DONE
