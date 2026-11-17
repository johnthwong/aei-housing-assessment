AEI Housing Center - Data Scientist Assessment

AEI's AI Usage Policy for This Assessment
AEI's scholarly work is fueled by rigorous, data-driven research, and we maintain policies and procedures for assuring the integrity and reputation of our work.

Candidates are encouraged, though not required, to use AI tools to support brainstorming, hypothesis testing, coding, editing, and exploratory analysis. AI is becoming an integral part of the modern workforce, and we want to see how candidates use it to sharpen, not substitute for, their own judgment, reasoning, and analysis. The quality of that use, including how you question, evaluate, and refine AI-generated output and the value you add beyond it, is part of the evaluation of this project.

There is no prescribed way to use AI in this assessment; we simply ask that you provide a complete record of your AI usage, including chats with agents, along with your final output. Candidates who submit incomplete AI transcripts or logs will be disqualified.

Instructions
This exercise assesses how you approach unfamiliar production data, what you judge to be worth building, and how you explain why it matters.
This assessment is timed and limited to 2 hours.
You may use R, Python, SQL, Stata, Excel or a BI tool for this assessment.
Data Context
The Housing Center receives a raw layout of the following data each month for roughly 175 million properties: assessor (annual and monthly update), deeds and mortgages, and automated valuation model (AVM estimates). In the zip file for this assessment, there are four property-records files for Baldwin County, Alabama. Dictionaries and code lookups are included; see the package README for formats and join keys.
Data files: https://drive.google.com/file/d/1dNVHxnBWaSLfueba0yQx-gAvGXbEKgeD/view?usp=sharing 
The data has been de-identified and perturbed to protect licensed and personal information. The structure and the messiness are real; the values are not. Do not draw real-world conclusions about Baldwin County from it.

Candidate tasks
Part 1 - Data profile (required, roughly 25 minutes)
Produce a short profile of the package (a table, a notebook, or a section of a memo), covering:
- Row and column counts for each file.
- How the files join: match rates, which key you used and why, and what the non-matches represent.
- Missingness for the columns you judge analytically important.
- Three to five data-quality issues, each with the evidence behind it.
- Anything else you deem interesting?
Part 2 - Choose one product (roughly 45 minutes)
Pick one of the following products that best shows the technical skills that you would bring to this role. One done well beats four started.
Visualization
A chart or a dashboard making the county's housing stock, values, ownership, or transaction activity understandable to a non-technical reader.
Database design
A schema and a prototype or pseudocode loader: keys, types, indexes, normalization, and your reasoning for each. What would this look like at national scale?
Analysis or modeling
A substantive finding and the code behind it:AVM versus assessed-value divergence, absentee or corporate ownership, transaction velocity, as examples
Automation and ingestion
Parameterized code that ingests these files and would extend to 3,000 counties monthly. Consider typing, validation, incremental loads, and failure handling.
If none of these fit as a showcase of your skills, build another product and include an explanation.
Part 3 - Memo (roughly 20 minutes, max 600 words)
- What product you built and why you chose it over the alternatives.
- The value-add of the product to a team maintaining this data monthly for every US county.
- What you would do next with the product, and what the limitations are.

 
Deliverables
1.	Memo, max 600 words, as a Word document or PDF.
2.	Your Part 1 profile and your Part 2 product.
3.	AI tool transcript or a log of the prompts you used.
Submission instructions
Submit as a single, zipped attachment, named "[Your Name] Housing Center Data Science Assessment – Memo/AI Log/Product". Do not paste your response into the body of the email.
Email the attachments to AEI's HR & Talent Development representative, and CC Arthur Gailes (Arthur.Gailes@aei.org) and Tobias Peter (Tobias.Peter@aei.org).
Additional guidance
- You are not expected to provide a fully polished product. We prioritize insight, reasoning, and clarity over completeness, and what you skipped and why is worth as much as what you built.
- In a later round, expect to walk through your code and defend your choices, tradeoffs, and limitations.
- If using an agent (e.g. Claude Code) you can retrieve your full transcript with the following prompt: Find all AI Agent (Claude Code, Codex, Cursor, etc) chat/session history associated with this project, including prior sessions not currently in context, and export the full user/assistant transcripts in chronological order to chat-history.md. Preserve the messages verbatim where possible, and exclude hidden reasoning, secrets, and irrelevant tool noise.
