# -*- mode: markdown -*-
---
layout   : post
title    : "baby's first emacs bug"
date     : 2012-10-01 19:26
comments : true
sharing  : true
tldr     : 
tags     : emacs, bug report, stack overflow
---

Like all emacsen, I have shaped my emacs environment over the years
until it fits me like a second skin. Recently an integral part of that
environment broke. After painstaking diagnosis, I determined that the
cause was an emacs bug and came up with a workaround. Lastly, I filed
my first emacs bug report!<!--more-->

## contents {#toc}

 * [problem](#problem)
 * [symptoms](#symptoms)
 * [hunt and gather](#hunt-and-gather)
 * [diagnosis](#diagnosis)
   * [approach](#approach)
   * [question](#question)
   * [plan (sketch)](#plan-sketch)
   * [action](#action)
   * [outcome](#outcome)
   * [drill down](#drill-down)

## problem

My Shell Switcher mode Customize settings stopped persisting across
emacs sessions. I've used Shell Switcher for a long time without any
problems, then \*poof*, the Customize settings stopped working. The
Shell Switcher related key bindings

    (global-set-key (kbd "C-'") 'shell-switcher-switch-buffer)
    (global-set-key (kbd "C-x 4 '") 'shell-switcher-switch-buffer-other-window)

I set outside of Customize in `.emacs` still worked, but the Shell
Switcher variables

    '(shell-switcher-mode t)
    '(shell-switcher-new-shell-function (quote shell-switcher-make-shell))

set through Customize did not. The Shell Switcher entries in Customize's
`custom-set-variables` in `.emacs` had not changed, they just weren't
working.

## symptoms

In a new emacs setting, `C-'` (switch buffer) triggered Shell Switcher:

    No active shell buffer, create new one? (y or n)
    
So far so good, that's one of the key bindings I set in `.emacs`. But
when I responded `y`, I could see Shell Switcher loading (it should
already have done that when I started emacs). 

Far more blatant, though, was that the buffer it launched was running 
the wrong shell: it came up in emacs shell.

Unlike `custom-set-variables` in `.emacs`, `Customize Apropos`
shell-switcher displayed the values for the two settings that matched
their behavior in a new emacs session:

| setting                           | value                      |
|-----------------------------------|----------------------------|
| shell-switcher-mode               | `nil`                      |
| shell-switcher-new-shell-function | shell-switcher-make-eshell |

Stranger still, both settings had `State: CHANGED outside Customize`

If I used Customize to set the values they would take and stay set
for that session. When next I launched emacs, however, they were
gone.

## hunt and gather

_skip this section if you aren't into software journaling_

When this happened I was mystified. I discovered something was wrong
when hitting `C-'` one day produced a buffer running the wrong shell.
I was deep in the midst of coding and wasn't going to drop everything
in order to diagnose a different problem: I reset the setting, made a
note of what had happened and got back to work.

Several days later, when I got my first chance to look at what was 
wrong, I could not identify any change in my emacs configuration that
might have caused the problem. I had not made any recent changes
except that I had started using the built-in irc client, erc. Nothing
unusual showed up in the Messages buffer. Running emacs with the 
debug switch didn't shed any light.

The `CHANGED outside Customize` thing really threw me. Was one of the
other packages, perhaps one that was a major mode, meddling with Shell
Switcher, which is, after all, a minor mode? I dug around the emacs
world for insight (emacswiki and friends), looked on
[stack](http://stackoverflow.com/), consulted the great oracle
of Google. I couldn't find anything (usually I can at least find
something that shakes my thinking loose so I can solve the problem).

In the end I wrote my first
[question](http://stackoverflow.com/questions/12536790/emacs-shell-switcher-customizations-being-overridden)
on stack. When I didn't get any answers to my question after
a day or so, I followed their advice and posted a link to it to
my Facebook feed. The discussion that followed was helpful in
that it validated that the solution was not obvious, lol.

I had projects that took priority. Time passed. I earned my
fourth stack badge: [tumbleweed](http://stackoverflow.com/badges/63/tumbleweed).

## diagnosis

### approach

When I finally made a few hours to tackle the problem, I used
an [internal fault model](http://blogs.msdn.com/b/james_whittaker/).

I developed an initial question and sketched out a plan based on 
possible outcomes. The ideal question:

* is testable without undue work;
* directly addresses the problem;
* has seperable, easy to detect, concrete outcomes;
* and moves the solution forwards regardless of outcome.

I don't require questions to have yes or no answers; it's more
valuable to have a question that reflects the underlying information
architecture.  The sketch of the plan addresses any difficulties with
not having yes/no answers, as it clearly identifies what each of the
outcomes mean. The sketch is a sketch because it makes no sense to
have some abstract, methodological requirement that an engineer expend
resources fleshing out many branches when only one will be
realized. That's what judgment is for, and methodology should support
judgment, not hamper it.
    
A second realm in which the engineer's judgment is critical comes in
weighing the relative importance of the listed criteria in context. As
we don't function in an ideal world, we often have to trade-off one
criteria with other(s). Note that context is wildly situational, as an
engineer makes progress diagnosing a problem the relative importance
of the criteria may change, even in the same problem. Perhaps the
easiest case to see is when, upon initial exploration, what appeared
to be a minor annoyance turns out to be a symptom of a deep-seated
problem. At that point, the definition of 'undue' shifts.

### question

> Question: Do Shell Switcher mode customizations persist across
> emacs sessions if there are no changes made outside
> `custom-set-variables`?

### plan (sketch)

Possible outcomes and associated next steps:

* Neither customization persists.

  This outcome would indicate:
  
  * that whatever was causing the setting to be rewritten was less
    to be a result of some other package interfering with the Shell
    Switcher mode settings
  * a bug in customize (the `CHANGED outside Customize` flag setting)
    As I was sketching out the plan, I remembered an answer I had seen
    on stack to a question concerning in Customize; the
    [answer](http://stackoverflow.com/questions/10042639/what-does-saved-and-set-mismatch-and-in-particular-the-mismatch-part-me) had identified a bug in Customize 
    associated with the same flag. I went digging for the question,
    while it did not shed light directly on my problem, it certainly
    helped with the fault model!

  In the case of this outcome, I could see two routes to follow:
  
  1. Comment out all entries in `custom-set-variables` except for
     the Shell Switcher entries to check for packages affecting 
     Shell Switcher programmatically, after all, if this path
     proved true I was also looking at two bugs.
  1. Move all the Shell Switcher configuration outside of Customize
     in my `.emacs` and see if it persisted across sessions. If
     so, at the least I would have a viable workaround. Less
     diagnostic value than the previous step, though.

* Both customizations persist.

  The inverse case; this outcome would suggest that something in
  my `.emacs` customizations was causing the problem.

  In this case, I would look for candidates to reintroduce that might
  be responsible. If all else failed, I could binary search my way through
  the list to find the culprit.

* The intermediate cases: Shell Switcher mode stays enabled but the
  buffer is launched in the wrong shell, or the buffer launches in the
  right shell but Shell Switcher mode is disabled.
  
  Neither case seemed either remotely likely. With not one, but two
  cases that fit my fault model, I decided not to put resources towards
  researching potential causes and paths for the intermediate cases.

### action

As I organized my `.emacs` into separate files by topic long ago, I
could turn off customizations outside of `custom-set-variables` 
by commenting out a few `load` statements:

    ; (load "~/.emacs.d/hilz_config/tramp.el")
    ; (load "~/.emacs.d/hilz_config/ruby_extensions.el")
    ; (load "~/.emacs.d/hilz_config/shell_switcher.el")
    ; (load "~/.emacs.d/hilz_config/personalize.el")

Then I used the Customize interface to

 * enable shell-switcher mode
 * set `shell-switcher-new-shell-function` to `shell-switcher-make-shell`

and hit `Apply and Save`. I opened `.emacs` and verified the presence of

    '(shell-switcher-mode t)
    '(shell-switcher-new-shell-function (quote shell-switcher-make-shell))

towards the end of the `custom-set-variables` entry. I restarted emacs.

### outcome

> Answer: No, the customizations were lost.

As I no longer was defining the key bindings, I now had to use `M-x
shell-switcher-new-shell` to test Shell Switcher. When I did, the
behavior I observed was the same as before: Shell Switcher loaded when
I used the command and the buffer came up in the wrong shell.

I looked in `.emacs`. The entries were still present in
`custom-set-variables`. I invoked Customize and saw what I've been
seeing all along:

 * the values for the shell-switcher variables did not match the values
   set in the `custom-set-variables` entry
 * the shell-switcher variables were shown as being in state `CHANGED
   outside Customize`.

No change.

### drill down

As the question appeared to me to have more diagnostic value, I started with

#### question

> Question: Do Shell Switcher mode customizations persist across
> emacs sessions if no other customizations are made in `.emacs`?

#### plan

Whichever outcome I got, I intended to move on to my second question from my
original plan next, as I needed a workaround and had spent quite a bit of time
on the issue that day by then (I kept notes, which I later expanded to this
post). If the Shell Switcher mode customizations persisted across emacs 
sessions when all the other customizations were commented out, then I would
return at a later date and tackle the issue as I would have had one of my
own customizations proven responsible.

#### action



The logical next question seems obvious to me:

> Question: Do shell-switcher mode variable values set outside of
> Customize persist across sessions?

By that I mean do I encounter the same problem if I use

    (setq shell-switcher-mode t)
    (setq shell-switcher-new-shell-function 'shell-switcher-make-shell)

instead of the Customize interface. (Could that really be the problem?
Wouldn't that be an emacs bug? I suppose it could be a bug in
shell-switcher mode. Gah. Gotta try it.)

Take the Shell Switcher lines out of the `custom-set-variables`
entry. Added the above two lines to my `.emacs`. Restart.

> Answer. O.M.G. Shell Switcher settings are just fine.
