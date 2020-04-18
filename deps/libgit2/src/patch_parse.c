static int git_parse_err(const char *fmt, ...) GIT_FORMAT_PRINTF(1, 2);
static int git_parse_err(const char *fmt, ...)
{
	va_list ap;

	va_start(ap, fmt);
	git_error_vset(GIT_ERROR_PATCH, fmt, ap);
	va_end(ap);

	return -1;
}

static size_t header_path_len(git_patch_parse_ctx *ctx)
		return error;
	if (path->size > 0 && path->ptr[0] == '"' &&
	    (error = git_buf_unquote(path)) < 0)
		return error;
	if (!path->size)
		return git_parse_err("patch contains empty path at line %"PRIuZ,
				     ctx->parse_ctx.line_num);

	return 0;
	int error;
	if ((error = parse_header_path_buf(&path, ctx, header_path_len(ctx))) < 0)
		goto out;
out:
	git_buf_dispose(&path);
	if (patch->old_path) {
		error = git_parse_err("patch contains duplicate old path at line %"PRIuZ,
				      ctx->parse_ctx.line_num);
		goto out;
	}

	git_buf_dispose(&old_path);
	if (patch->new_path) {
		error = git_parse_err("patch contains duplicate new path at line %"PRIuZ,
				      ctx->parse_ctx.line_num);
	}
	if ((error = parse_header_path_buf(&new_path, ctx, ctx->parse_ctx.line_len - 1)) <  0)
		goto out;
	git_buf_dispose(&new_path);
	git__free((char *)patch->base.delta->new_file.path);
	patch->base.delta->new_file.path = NULL;
	git__free((char *)patch->base.delta->old_file.path);
	patch->base.delta->old_file.path = NULL;
	*out = (uint16_t)val;
	if (!git_parse_ctx_contains(&ctx->parse_ctx, "\n", 1) &&
	    !git_parse_ctx_contains(&ctx->parse_ctx, "\r\n", 2)) {
	{ "--- "                , STATE_DIFF,       STATE_PATH,       parse_header_git_oldpath },
	{ "similarity index "   , STATE_END,        STATE_SIMILARITY, parse_header_similarity },
	{ "-- "                 , STATE_INDEX,      0,                NULL },
	int64_t num;
	git_error_set(GIT_ERROR_PATCH, "invalid patch hunk header at line %"PRIuZ,
static int eof_for_origin(int origin) {
	if (origin == GIT_DIFF_LINE_ADDITION)
		return GIT_DIFF_LINE_ADD_EOFNL;
	if (origin == GIT_DIFF_LINE_DELETION)
		return GIT_DIFF_LINE_DEL_EOFNL;
	return GIT_DIFF_LINE_CONTEXT_EOFNL;
}

	int last_origin = 0;
		int old_lineno, new_lineno, origin, prefix = 1;

		if (git__add_int_overflow(&old_lineno, hunk->hunk.old_start, hunk->hunk.old_lines) ||
		    git__sub_int_overflow(&old_lineno, old_lineno, oldlines) ||
		    git__add_int_overflow(&new_lineno, hunk->hunk.new_start, hunk->hunk.new_lines) ||
		    git__sub_int_overflow(&new_lineno, new_lineno, newlines)) {
			error = git_parse_err("unrepresentable line count at line %"PRIuZ,
					      ctx->parse_ctx.line_num);
			goto done;
		}
			new_lineno = -1;
			old_lineno = -1;
		case '\\':
			/*
			 * If there are no oldlines left, then this is probably
			 * the "\ No newline at end of file" marker. Do not
			 * verify its format, as it may be localized.
			 */
			if (!oldlines) {
				prefix = 0;
				origin = eof_for_origin(last_origin);
				old_lineno = -1;
				new_lineno = -1;
				break;
			}
			/* fall through */

		GIT_ERROR_CHECK_ALLOC(line);
		line->content = git__strndup(ctx->parse_ctx.line + prefix, line->content_len);
		GIT_ERROR_CHECK_ALLOC(line->content);
		line->num_lines = 1;
		line->old_lineno = old_lineno;
		line->new_lineno = new_lineno;

		last_origin = origin;
	/*
	 * Handle "\ No newline at end of file". Only expect the leading
			error = git_parse_err("last line has no trailing newline");
		line = git_array_alloc(patch->base.lines);
		GIT_ERROR_CHECK_ALLOC(line);

		memset(line, 0x0, sizeof(git_diff_line));

		line->content_len = ctx->parse_ctx.line_len;
		line->content = git__strndup(ctx->parse_ctx.line, line->content_len);
		GIT_ERROR_CHECK_ALLOC(line->content);
		line->content_offset = ctx->parse_ctx.content_len - ctx->parse_ctx.remain_len;
		line->origin = eof_for_origin(last_origin);
		line->num_lines = 1;
		line->old_lineno = -1;
		line->new_lineno = -1;

		hunk->line_count++;
				git_error_clear();
	git_error_set(GIT_ERROR_PATCH, "no patch found");
	int64_t len;
		if (!encoded_len || !ctx->parse_ctx.line_len || encoded_len > ctx->parse_ctx.line_len - 1) {
	git_buf_dispose(&base85);
	git_buf_dispose(&decoded);
	const char *old = patch->old_path ? patch->old_path : patch->header_old_path;
	const char *new = patch->new_path ? patch->new_path : patch->header_new_path;

	if (!old || !new)
		return git_parse_err("corrupt binary data without paths at line %"PRIuZ, ctx->parse_ctx.line_num);

	if (patch->base.delta->status == GIT_DELTA_ADDED)
		old = "/dev/null";
	else if (patch->base.delta->status == GIT_DELTA_DELETED)
		new = "/dev/null";

	    git_parse_advance_expected_str(&ctx->parse_ctx, old) < 0 ||
	    git_parse_advance_expected_str(&ctx->parse_ctx, " and ") < 0 ||
	    git_parse_advance_expected_str(&ctx->parse_ctx, new) < 0 ||
	    git_parse_advance_expected_str(&ctx->parse_ctx, " differ") < 0 ||
	    git_parse_advance_nl(&ctx->parse_ctx) < 0)
		GIT_ERROR_CHECK_ALLOC(hunk);
	if (check_header_names(patch->header_old_path, patch->old_path, "old", added) < 0 ||
	    check_header_names(patch->header_new_path, patch->new_path, "new", deleted) < 0)
	prefixed_old = (!added && patch->old_path) ? patch->old_path : patch->header_old_path;
	prefixed_new = (!deleted && patch->new_path) ? patch->new_path : patch->header_new_path;
	if ((prefixed_old && check_prefix(&patch->old_prefix, &old_prefixlen, patch, prefixed_old) < 0) ||
	    (prefixed_new && check_prefix(&patch->new_prefix, &new_prefixlen, patch, prefixed_new) < 0))
	else if (prefixed_old)
	else
		patch->base.delta->old_file.path = NULL;
	else if (prefixed_new)
	else
		patch->base.delta->new_file.path = NULL;
	    !patch->base.delta->new_file.path)
	    delta->status != GIT_DELTA_DELETED &&
	    !delta->new_file.mode)
	    !(delta->flags & GIT_DIFF_FLAG_BINARY) &&
	    delta->new_file.mode == delta->old_file.mode &&
	    git_array_size(patch->base.hunks) == 0)
	git_diff_line *line;
	size_t i;
	git_array_foreach(patch->base.lines, i, line)
		git__free((char *) line->content);
	GIT_ERROR_CHECK_ALLOC(patch);
	GIT_ERROR_CHECK_ALLOC(patch->base.delta);
	GIT_ERROR_CHECK_ALLOC(ctx);