#!/usr/bin/env python3
import argparse
import os
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import matplotlib.animation as animation


def main():
    parser = argparse.ArgumentParser(description="nObjectsEngine High-FPS Video Generator")
    parser.add_argument("-i", "--input", default="output/output.csv", help="Path to trajectory CSV file")
    parser.add_argument("-o", "--output", default="renders/orbit_60fps.mp4", help="Path to save MP4 video")
    parser.add_argument("--fps", type=int, default=60, help="Video framerate (default: 60)")
    parser.add_argument("--speedup", type=int, default=1, help="Steps per frame to speed up orbit (e.g., 2 or 4)")
    parser.add_argument("--trail", type=int, default=150, help="Length of historical trail points")
    args = parser.parse_args()

    if not os.path.exists(args.input):
        print(f"Error: Input file '{args.input}' not found.")
        return

    os.makedirs(os.path.dirname(args.output), exist_ok=True)

    print(f"Loading trajectory data from {args.input}...")
    df = pd.read_csv(args.input)

    # Clean whitespace from column names if present
    df.columns = [c.strip() for c in df.columns]

    # Auto-detect position columns
    def find_col(candidates):
        for c in candidates:
            if c in df.columns:
                return c
        raise KeyError(f"Could not find position columns from candidates {candidates}. Available: {list(df.columns)}")

    x_col = find_col(["posX", "pos_x", "x", "px"])
    y_col = find_col(["posY", "pos_y", "y", "py"])

    # Extract time steps (apply speedup step skip if desired)
    times = np.sort(df["time"].unique())[::args.speedup]
    body_ids = np.sort(df["id"].unique())

    # Set up dark styled Matplotlib figure
    fig, ax = plt.subplots(figsize=(8, 8), facecolor="#0e1117")
    ax.set_facecolor("#0e1117")

    # Fixed spatial boundary limits
    max_bound = max(abs(df[x_col]).max(), abs(df[y_col]).max()) * 1.15
    ax.set_xlim(-max_bound, max_bound)
    ax.set_ylim(-max_bound, max_bound)
    ax.set_aspect("equal")

    ax.tick_params(colors="white")
    ax.xaxis.label.set_color("white")
    ax.yaxis.label.set_color("white")
    ax.title.set_color("white")
    ax.grid(True, linestyle="--", alpha=0.15)
    ax.set_xlabel("X Position (m)")
    ax.set_ylabel("Y Position (m)")
    ax.set_title("nObjectsEngine - Kepler Orbit (60 FPS)")

    # Color map & scene elements
    cmap = plt.get_cmap("plasma", len(body_ids))
    lines = {}
    points = {}

    for idx, b_id in enumerate(body_ids):
        color = "#ffcc00" if b_id == 1 else "#00d2ff"  # Sun yellow, Earth cyan
        size = 12 if b_id == 1 else 6
        
        (line,) = ax.plot([], [], lw=1.5, alpha=0.6, color=color)
        (point,) = ax.plot([], [], "o", markersize=size, color=color, label=f"Body {b_id}")
        lines[b_id] = line
        points[b_id] = point

    ax.legend(facecolor="#1a1c23", edgecolor="none", labelcolor="white", loc="upper right")

    def init():
        for b_id in body_ids:
            lines[b_id].set_data([], [])
            points[b_id].set_data([], [])
        return list(lines.values()) + list(points.values())

    def update(frame):
        t = times[frame]
        sub_df = df[df["time"] <= t]

        for b_id in body_ids:
            b_df = sub_df[sub_df["id"] == b_id].tail(args.trail)
            if not b_df.empty:
                lines[b_id].set_data(b_df[x_col].values, b_df[y_col].values)
                curr = b_df.iloc[-1]
                points[b_id].set_data([curr[x_col]], [curr[y_col]])

        return list(lines.values()) + list(points.values())

    print(f"Generating 60 FPS video ({len(times)} frames)...")
    anim = animation.FuncAnimation(
        fig, update, frames=len(times), init_func=init, blit=True
    )

    # Save video via ffmpeg
    writer = animation.FFMpegWriter(fps=args.fps, bitrate=2000)
    anim.save(args.output, writer=writer)
    plt.close()

    print(f"60 FPS video render complete: {args.output}")
    os.system(f"open {args.output}")


if __name__ == "__main__":
    main()