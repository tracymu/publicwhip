<pre>GET <%= api_v1_policy_url(format: "json", id: "foo").gsub("foo", "[id]") %></pre>

For example

<pre>GET <%= link_to api_v1_policy_url(format: "json", id: 1), api_v1_policy_url(format: "json", id: 1) %></pre>

This returns all sorts of useful detailed information, including

Parameter            | Description
-------------------- | ------------------------------------------------------------------------
`id`                 | A unique identifier for this division. Use the `id` to get more information about this policy
`name`               | A short name for the policy
`description`        | More detail on what the policy means
`provisional`        | `true` or `false`. A provisional policy isn't yet "complete" and isn't visible by default in comparisons with people
`policy_divisions`   | An array of divisions connected to this policy. Each division also has an associated `vote` which can be `strong` which makes the vote more important
`people_comparisons` | An array of people who could have voted on this division and their calculated `agreement` score in range from 0 to 100. `voted` says whether they ever vote on a division from this policy.
