---
name: testing-multiple-clients
description: Use when testing scenarios involving multiple browser tabs, sessions, or real-time broadcasts in lamdera/program-test
---

# Testing Multiple Clients in lamdera/program-test

## The Wrong Way (Sibling Connections)

**Don't** connect multiple clients as siblings - they run sequentially (each sibling runs AFTER the previous one completes):

```elm
-- WRONG: clientB runs AFTER clientA finishes completely
Effect.Test.start "My test" time config
    [ Effect.Test.connectFrontend 1000 session1 "/" size (\clientA -> [...])
    , Effect.Test.connectFrontend 1500 session1 "/" size (\clientB -> [...])  -- Runs after clientA is done
    ]
```

This means clientA can't check results of clientB's actions.

## The Right Way (Nested Connections)

Connect subsequent clients **inside** the first client's action list:

```elm
Effect.Test.start "My test" time config
    [ Effect.Test.connectFrontend 1000 session1 "/" size
        (\clientA ->
            [ clientA.click 100 (Dom.id "some-button")
            , -- Connect clientB INSIDE clientA's actions
              Effect.Test.connectFrontend 0 session1 "/" size
                (\clientB ->
                    [ clientB.checkView 100 (...)
                    , -- Now both clients can be referenced
                      clientA.checkView 100 (...)
                    ]
                )
            ]
        )
    ]
```

## Waiting for Backend Processing

Use `Effect.Test.andThen` to wait for backend broadcasts:

```elm
Effect.Test.connectFrontend 0 session1 "/trigger-action" size
    (\clientB ->
        [ clientB.checkView 100 (...)  -- clientB triggers something
        , Effect.Test.andThen 500      -- Wait for backend to process
            (\_ ->
                [ -- Now check that clientA received the broadcast
                  clientA.checkView 0 (Test.Html.Query.has [ exactText "Updated!" ])
                ]
            )
        ]
    )
```

## Key Points

1. **Nest connections** - Don't use sibling `connectFrontend` calls for coordinated tests
2. **Use `andThen`** - Wait for backend processing before checking broadcast results
3. **Reference outer clients** - Inner callbacks can reference `clientA`, `clientB`, etc. from outer scopes
4. **Delay of 0** - Nested connections can use delay `0` since they're sequenced by nesting
5. **500ms wait** - Typically sufficient for backend broadcast round-trip
