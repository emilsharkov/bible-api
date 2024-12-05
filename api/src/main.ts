import express, { Request, Response } from "express";

const app = express();
const PORT: number = 8000;

app.get("/", (req: Request, res: Response) => {
  res.send("Welcome to the Dinosaur API!");
});

app.get("/jesus", (req: Request, res: Response) => {
  res.send("Welcome to the Jesus API!");
});

app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});