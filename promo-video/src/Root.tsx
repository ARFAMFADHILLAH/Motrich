import React from "react";
import { Composition, Folder } from "remotion";
import { MotrichPromo } from "./MotrichPromo";
import { OpeningScene } from "./scenes/OpeningScene";
import { ProblemScene } from "./scenes/ProblemScene";
import { DashboardScene } from "./scenes/DashboardScene";
import { TransactionScene } from "./scenes/TransactionScene";
import { BudgetScene } from "./scenes/BudgetScene";
import { FeaturesScene } from "./scenes/FeaturesScene";
import { DualModeScene } from "./scenes/DualModeScene";
import { CtaScene } from "./scenes/CtaScene";

const WIDTH = 1080;
const HEIGHT = 1920;
const FPS = 30;

export const RemotionRoot: React.FC = () => {
  return (
    <>
      <Folder name="Scenes">
        <Composition
          id="Opening"
          component={OpeningScene}
          width={WIDTH}
          height={HEIGHT}
          fps={FPS}
          durationInFrames={100}
        />
        <Composition
          id="Problem"
          component={ProblemScene}
          width={WIDTH}
          height={HEIGHT}
          fps={FPS}
          durationInFrames={80}
        />
        <Composition
          id="Dashboard"
          component={DashboardScene}
          width={WIDTH}
          height={HEIGHT}
          fps={FPS}
          durationInFrames={120}
        />
        <Composition
          id="Transaction"
          component={TransactionScene}
          width={WIDTH}
          height={HEIGHT}
          fps={FPS}
          durationInFrames={130}
        />
        <Composition
          id="Budget"
          component={BudgetScene}
          width={WIDTH}
          height={HEIGHT}
          fps={FPS}
          durationInFrames={130}
        />
        <Composition
          id="Features"
          component={FeaturesScene}
          width={WIDTH}
          height={HEIGHT}
          fps={FPS}
          durationInFrames={130}
        />
        <Composition
          id="DualMode"
          component={DualModeScene}
          width={WIDTH}
          height={HEIGHT}
          fps={FPS}
          durationInFrames={130}
        />
        <Composition
          id="CTA"
          component={CtaScene}
          width={WIDTH}
          height={HEIGHT}
          fps={FPS}
          durationInFrames={150}
        />
      </Folder>

      <Composition
        id="MotrichPromo"
        component={MotrichPromo}
        width={WIDTH}
        height={HEIGHT}
        fps={FPS}
        durationInFrames={900}
      />
    </>
  );
};
