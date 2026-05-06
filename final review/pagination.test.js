const { parsePagination, createPaginationMeta } = require("../src/utils/pagination");

describe("pagination utils", () => {
  test("parsePagination should sanitize invalid values", () => {
    const result = parsePagination({ page: "-5", limit: "200" });

    expect(result.page).toBe(1);
    expect(result.limit).toBe(50);
    expect(result.offset).toBe(0);
  });

  test("createPaginationMeta should compute total pages", () => {
    const meta = createPaginationMeta(23, 2, 6);
    expect(meta.totalPages).toBe(4);
  });
});
