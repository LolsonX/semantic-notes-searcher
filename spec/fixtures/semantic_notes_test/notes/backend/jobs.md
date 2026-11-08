# Background Job Processing

Long-running work such as sending email or resizing images should be queued rather than executed during an HTTP request. Workers consume jobs asynchronously, retry transient failures, and record permanent failures for investigation.
