import { useEffect, useState } from "react";
import "./App.css";

export default function ChanakyaLinkDashboard() {
  const [selectedNode, setSelectedNode] = useState(2);
  const [command, setCommand] = useState("ACTIVATE");
  const [delay, setDelay] = useState(5000);
  const [checksum, setChecksum] = useState(61);
  const [systemLog, setSystemLog] = useState([]);
  const [executionStatus, setExecutionStatus] = useState("IDLE");
  const [countdown, setCountdown] = useState(null);
  const [frame, setFrame] = useState("#2,1,5000,61*");

  const generateChecksum = (id, cmd, delayVal) => {
    return (id ^ cmd ^ (delayVal & 255) ^ ((delayVal >> 8) & 255)) % 100;
  };

  const generateFrame = () => {
    const cmdValue = command === "ACTIVATE" ? 1 : 0;
    const crc = generateChecksum(selectedNode, cmdValue, delay);

    setChecksum(crc);

    const generatedFrame = `#${selectedNode},${cmdValue},${delay},${crc}*`;
    setFrame(generatedFrame);

    setSystemLog((prev) => [
      "[MASTER] AI Decision Received",
      `[AI] Selected Slave Node ${selectedNode}`,
      `[MASTER] Communication Frame Generated : ${generatedFrame}`,
      ...prev,
    ]);
  };

  const startTransmission = () => {
    generateFrame();

    setExecutionStatus("TRANSMITTING");

    setTimeout(() => {
      setSystemLog((prev) => [
        `[SLAVE ${selectedNode}] Frame Received Successfully`,
        `[SLAVE ${selectedNode}] Checksum Verification PASSED`,
        `[SLAVE ${selectedNode}] Delay Synchronization Started`,
        ...prev,
      ]);

      setExecutionStatus("VERIFYING");

      let timeLeft = delay / 1000;
      setCountdown(timeLeft);

      const timer = setInterval(() => {
        timeLeft -= 1;
        setCountdown(timeLeft);

        if (timeLeft <= 0) {
          clearInterval(timer);

          setExecutionStatus("EXECUTED");

          setSystemLog((prev) => [
            `[ACTION] Slave Node ${selectedNode} Executed ${command}`,
            `[SYSTEM] Sequential Detonation Successful`,
            ...prev,
          ]);
        }
      }, 1000);
    }, 1500);
  };

  const slaveNodes = [
    { id: 1, status: "ACTIVE", delay: "2000 ms" },
    { id: 2, status: "ACTIVE", delay: "5000 ms" },
    { id: 3, status: "ACTIVE", delay: "8000 ms" },
    { id: 4, status: "ACTIVE", delay: "12000 ms" },
  ];

  useEffect(() => {
    setSystemLog([
      "[MASTER] System Initialized",
      "[MASTER] Scanning Slave Nodes...",
      "[INFO] Slave Node 1 Connected",
      "[INFO] Slave Node 2 Connected",
      "[INFO] Slave Node 3 Connected",
      "[INFO] Slave Node 4 Connected",
    ]);
  }, []);

  return (
    <div className="min-h-screen bg-gradient-to-br from-slate-950 via-blue-950 to-orange-950 text-white p-6 font-sans overflow-hidden">
      <div className="absolute inset-0 opacity-20 bg-[radial-gradient(circle_at_center,_#22d3ee_0,_transparent_40%),radial-gradient(circle_at_top_right,_#fb923c_0,_transparent_35%)]"></div>

      <div className="relative z-10">
        {/* Header */}
        <div className="flex flex-col lg:flex-row lg:items-center lg:justify-between gap-6 mb-8 border-b border-cyan-500/30 pb-6">
          <div>
            <h1 className="text-5xl md:text-6xl font-black tracking-wider text-cyan-300 drop-shadow-lg">
              CHANAKYALINK
            </h1>
            <p className="text-orange-200 mt-3 text-lg tracking-wide">
              AI-Assisted Sequential Mining Blast Protocol
            </p>
          </div>

          <div className="bg-black/40 border border-cyan-500/40 rounded-3xl px-8 py-5 shadow-2xl shadow-cyan-500/20 backdrop-blur-md">
            <p className="text-gray-300 text-sm tracking-widest">SYSTEM STATUS</p>
            <h2 className="text-3xl font-bold text-green-400 mt-2 animate-pulse">
              ONLINE
            </h2>
          </div>
        </div>

        {/* Main Grid */}
        <div className="main-grid">
        
          {/* AI Control Panel */}
          <div className="bg-black/30 border border-cyan-500/20 rounded-3xl p-6 backdrop-blur-xl shadow-2xl">
            <h2 className="text-2xl font-bold text-cyan-300 mb-6 tracking-wide">
              AI CONTROL PANEL
            </h2>

            <div className="space-y-5">
              <div>
                <label className="block text-sm text-gray-300 mb-2">
                  Select Slave Node
                </label>
                <select
                  value={selectedNode}
                  onChange={(e) => setSelectedNode(Number(e.target.value))}
                  className="w-full bg-slate-900 border border-cyan-500/30 rounded-2xl px-4 py-4 text-cyan-300 text-lg outline-none"
                >
                  <option value={1}>Slave Node 1</option>
                  <option value={2}>Slave Node 2</option>
                  <option value={3}>Slave Node 3</option>
                  <option value={4}>Slave Node 4</option>
                </select>
              </div>

              <div>
                <label className="block text-sm text-gray-300 mb-2">
                  Command Type
                </label>
                <select
                  value={command}
                  onChange={(e) => setCommand(e.target.value)}
                  className="w-full bg-slate-900 border border-orange-400/30 rounded-2xl px-4 py-4 text-orange-300 text-lg outline-none"
                >
                  <option>ACTIVATE</option>
                  <option>DEACTIVATE</option>
                </select>
              </div>

              <div>
                <label className="block text-sm text-gray-300 mb-2">
                  Execution Delay (ms)
                </label>
                <input
                  type="range"
                  min="1000"
                  max="12000"
                  step="1000"
                  value={delay}
                  onChange={(e) => setDelay(Number(e.target.value))}
                  className="w-full"
                />

                <div className="text-center mt-3 text-3xl font-bold text-cyan-300">
                  {delay} ms
                </div>
              </div>

              <button
                onClick={generateFrame}
                className="w-full bg-gradient-to-r from-cyan-500 to-blue-600 hover:scale-105 transition-all duration-300 rounded-2xl py-4 text-xl font-bold shadow-lg shadow-cyan-500/30"
              >
                GENERATE FRAME
              </button>

              <button
                onClick={startTransmission}
                className="w-full bg-gradient-to-r from-orange-400 to-orange-600 hover:scale-105 transition-all duration-300 rounded-2xl py-4 text-xl font-bold shadow-lg shadow-orange-500/30"
              >
                START TRANSMISSION
              </button>
            </div>
          </div>

          {/* Communication Frame */}
          <div className="bg-black/30 border border-cyan-500/20 rounded-3xl p-6 backdrop-blur-xl shadow-2xl">
            <h2 className="text-2xl font-bold text-cyan-300 mb-6 tracking-wide">
              COMMUNICATION FRAME
            </h2>

            <div className="bg-slate-950 border border-cyan-400/30 rounded-3xl p-8 text-center shadow-inner shadow-cyan-500/20">
              <p className="text-gray-400 mb-4 text-lg">Generated Frame</p>

              <div className="text-4xl md:text-5xl font-black text-orange-300 tracking-wider break-all">
                {frame}
              </div>
            </div>

            <div className="mt-8 grid grid-cols-2 gap-4">
              <div className="bg-slate-900/70 rounded-2xl p-4 border border-cyan-500/20">
                <p className="text-gray-400 text-sm">Slave ID</p>
                <h3 className="text-3xl font-bold text-cyan-300 mt-2">
                  {selectedNode}
                </h3>
              </div>

              <div className="bg-slate-900/70 rounded-2xl p-4 border border-orange-400/20">
                <p className="text-gray-400 text-sm">Command</p>
                <h3 className="text-2xl font-bold text-orange-300 mt-2">
                  {command}
                </h3>
              </div>

              <div className="bg-slate-900/70 rounded-2xl p-4 border border-cyan-500/20">
                <p className="text-gray-400 text-sm">Delay</p>
                <h3 className="text-2xl font-bold text-cyan-300 mt-2">
                  {delay} ms
                </h3>
              </div>

              <div className="bg-slate-900/70 rounded-2xl p-4 border border-cyan-500/20">
                <p className="text-gray-400 text-sm">Checksum</p>
                <h3 className="text-3xl font-bold text-cyan-300 mt-2">
                  {checksum}
                </h3>
              </div>
            </div>

            <div className="mt-8 bg-gradient-to-r from-cyan-500/10 to-orange-400/10 border border-cyan-500/20 rounded-3xl p-6 text-center">
              <p className="text-gray-300 text-sm tracking-widest">
                EXECUTION STATUS
              </p>

              <h2 className="text-3xl font-black mt-3 text-orange-300">
                {executionStatus}
              </h2>

              {countdown !== null && countdown > 0 && (
                <div className="mt-4 text-5xl font-black text-cyan-300 animate-pulse">
                  {countdown}s
                </div>
              )}
            </div>
          </div>

          {/* Slave Nodes */}
          <div className="bg-black/30 border border-cyan-500/20 rounded-3xl p-6 backdrop-blur-xl shadow-2xl">
            <h2 className="text-2xl font-bold text-cyan-300 mb-6 tracking-wide">
              SLAVE NODE STATUS
            </h2>

            <div className="space-y-5">
              {slaveNodes.map((node) => (
                <div
                  key={node.id}
                  className={`rounded-3xl p-5 border transition-all duration-500 ${
                    selectedNode === node.id
                      ? "border-orange-400 bg-orange-500/10 scale-105 shadow-lg shadow-orange-500/20"
                      : "border-cyan-500/20 bg-slate-900/70"
                  }`}
                >
                  <div className="flex items-center justify-between">
                    <h3 className="text-xl font-bold tracking-wide">
                      SLAVE NODE {node.id}
                    </h3>

                    <div
                      className={`px-4 py-2 rounded-full text-sm font-bold ${
                        selectedNode === node.id
                          ? "bg-orange-500 text-black"
                          : "bg-cyan-500 text-black"
                      }`}
                    >
                      {selectedNode === node.id ? "SELECTED" : "READY"}
                    </div>
                  </div>

                  <div className="mt-4 space-y-2 text-gray-300">
                    <p>Status : {node.status}</p>
                    <p>Configured Delay : {node.delay}</p>
                  </div>
                </div>
              ))}
            </div>
          </div>
        </div>

        {/* System Monitor */}
        <div className="mt-8 bg-black/30 border border-cyan-500/20 rounded-3xl p-6 backdrop-blur-xl shadow-2xl">
          <h2 className="text-2xl font-bold text-cyan-300 mb-6 tracking-wide">
            SYSTEM MONITOR
          </h2>

          <div className="bg-slate-950 rounded-3xl border border-cyan-500/20 p-6 h-[300px] overflow-y-auto space-y-3 font-mono text-sm">
            {systemLog.map((log, index) => (
              <div
                key={index}
                className="text-green-400 border-b border-slate-800 pb-2"
              >
                {log}
              </div>
            ))}
          </div>
        </div>
      </div>
    </div>
  );
}
