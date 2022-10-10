import { cacheDir as ghactionsToolCacheCacheDirectory } from "@actions/tool-cache";
const input = JSON.parse(process.argv[2]);
const result = await ghactionsToolCacheCacheDirectory(input.Source, input.Name, input.Version, input.Architecture)
	.catch((reason) => {
		console.error(reason);
		return process.exit(1);
	});
console.log(process.argv[3]);
console.log(JSON.stringify({ Path: result }));
