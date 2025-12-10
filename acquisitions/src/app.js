import express from "express";

const app = express();

app.get("/", (req, res) => {
  res.status(200).send("Hello from Acquisitions!");
});
app.get("/health", (req, res) => {
  res.status(200).json({
    status: "OK",
    timestamp: new Date().toISOString(),
    uptime: process.uptime(),
  });
});

app.get("/api", (req, res) => {
  res.status(200).json({ message: "Acquisitions API is running!" });
});

app.use((req, res) => {
  res.status(404).json({ error: "Route not found" });
});

export default app;
