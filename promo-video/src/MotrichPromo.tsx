import React from "react";
import { AbsoluteFill, Audio, staticFile } from "remotion";
import { linearTiming, TransitionSeries } from "@remotion/transitions";
import { fade } from "@remotion/transitions/fade";
import { slide } from "@remotion/transitions/slide";
import { OpeningScene } from "./scenes/OpeningScene";
import { ProblemScene } from "./scenes/ProblemScene";
import { DashboardScene } from "./scenes/DashboardScene";
import { TransactionScene } from "./scenes/TransactionScene";
import { BudgetScene } from "./scenes/BudgetScene";
import { FeaturesScene } from "./scenes/FeaturesScene";
import { DualModeScene } from "./scenes/DualModeScene";
import { CtaScene } from "./scenes/CtaScene";
import { COLORS } from "./theme";

const TRANSITION = 10;

export const MotrichPromo: React.FC = () => {
  return (
    <AbsoluteFill style={{ background: COLORS.bgDeep }}>
      <Audio src={staticFile("audio/fullaudio.mp3")} />
      <TransitionSeries>
        <TransitionSeries.Sequence durationInFrames={100} name="Opening">
          <OpeningScene />
        </TransitionSeries.Sequence>

        <TransitionSeries.Transition
          presentation={fade()}
          timing={linearTiming({ durationInFrames: TRANSITION })}
        />

        <TransitionSeries.Sequence durationInFrames={80} name="Problem">
          <ProblemScene />
        </TransitionSeries.Sequence>

        <TransitionSeries.Transition
          presentation={slide({ direction: "from-right" })}
          timing={linearTiming({ durationInFrames: TRANSITION })}
        />

        <TransitionSeries.Sequence durationInFrames={120} name="Dashboard">
          <DashboardScene />
        </TransitionSeries.Sequence>

        <TransitionSeries.Transition
          presentation={fade()}
          timing={linearTiming({ durationInFrames: TRANSITION })}
        />

        <TransitionSeries.Sequence durationInFrames={130} name="Transaction">
          <TransactionScene />
        </TransitionSeries.Sequence>

        <TransitionSeries.Transition
          presentation={slide({ direction: "from-right" })}
          timing={linearTiming({ durationInFrames: TRANSITION })}
        />

        <TransitionSeries.Sequence durationInFrames={130} name="Budget">
          <BudgetScene />
        </TransitionSeries.Sequence>

        <TransitionSeries.Transition
          presentation={fade()}
          timing={linearTiming({ durationInFrames: TRANSITION })}
        />

        <TransitionSeries.Sequence durationInFrames={130} name="Features">
          <FeaturesScene />
        </TransitionSeries.Sequence>

        <TransitionSeries.Transition
          presentation={fade()}
          timing={linearTiming({ durationInFrames: TRANSITION })}
        />

        <TransitionSeries.Sequence durationInFrames={220} name="DualMode">
          <DualModeScene />
        </TransitionSeries.Sequence>

        <TransitionSeries.Transition
          presentation={fade()}
          timing={linearTiming({ durationInFrames: TRANSITION })}
        />

        <TransitionSeries.Sequence durationInFrames={60} name="CTA" trimBefore={43}>
          <CtaScene />
        </TransitionSeries.Sequence>
      </TransitionSeries>
    </AbsoluteFill>
  );
};
