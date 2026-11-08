# Semantic Notes Search validation fixtures

18 Markdown notes across security, backend, devops, and personal topics.

## Use

```bash
notes index ./notes
notes stats
notes search "How do I speed up repeated requests to my service?" --limit 5
```

Use `validation_queries.csv` as a relevance test set. `expected_top_result` is the intended best match, **not a guaranteed top-1 prediction** for every embedding model. `related_optional_result` is a plausible related note, not a strict required match.

Suggested evaluation: Top-1 accuracy = queries whose expected note ranks first / total queries. Recall@3 = queries whose expected note appears in the first three results / total queries. Start by checking Recall@3; results depend on the embedding model.

## Additional functional tests

1. Reindex unchanged files: no embeddings should be regenerated.
2. Edit one note and reindex: only that note should update.
3. Search with an empty index: show an informative message.
4. Stop Ollama and search: show a clear connection error.
5. Change the embedding model: refuse incompatible comparisons or require reindexing.
6. Search with `--limit 1`: return at most one result.

All notes are synthetic test content.
