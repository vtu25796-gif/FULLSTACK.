const { hashPassword, comparePassword } = require("../src/utils/password");

describe("password utils", () => {
  test("hashPassword + comparePassword should validate correct input", async () => {
    const plain = "StrongPass123";
    const hash = await hashPassword(plain);

    expect(hash).not.toBe(plain);
    const isValid = await comparePassword(plain, hash);
    expect(isValid).toBe(true);
  });

  test("comparePassword should reject wrong password", async () => {
    const hash = await hashPassword("StrongPass123");
    const isValid = await comparePassword("WrongPass", hash);
    expect(isValid).toBe(false);
  });
});
